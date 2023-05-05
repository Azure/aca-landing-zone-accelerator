
module "hub" {
  source                       = "./modules/01-hub"
  workloadName                 = var.workloadName
  environment                  = var.environment
  hubResourceGroupName         = var.hubResourceGroupName
  vnetAddressPrefixes          = var.hubVnetAddressPrefixes
  enableBastion                = var.enableBastion
  bastionSubnetAddressPrefixes = var.bastionSubnetAddressPrefixes
  vmSize                       = var.vmSize
  vmAdminUsername              = var.vmAdminUsername
  vmAdminPassword              = var.vmAdminPassword
  vmLinuxSshAuthorizedKeys     = var.vmLinuxSshAuthorizedKeys
  vmJumpboxOSType              = var.vmJumpboxOSType
  vmJumpBoxSubnetAddressPrefix = var.vmJumpBoxSubnetAddressPrefix
  tags                         = var.tags
}

module "spoke" {
  source                                = "./modules/02-spoke"
  workloadName                          = var.workloadName
  environment                           = var.environment
  spokeResourceGroupName                = var.spokeResourceGroupName
  vnetAddressPrefixes                   = var.spokeVnetAddressPrefixes
  infraSubnetAddressPrefix              = var.infraSubnetAddressPrefix
  infraSubnetName                       = var.infraSubnetName
  privateEndpointsSubnetAddressPrefix   = var.privateEndpointsSubnetAddressPrefix
  applicationGatewaySubnetAddressPrefix = var.applicationGatewaySubnetAddressPrefix
  hubVnetId                             = module.hub.hubVnetId
  securityRules                         = var.securityRules
  tags                                  = var.tags

  # depends_on = [module.module.hub]
}

module "supportingServices" {
  source                              = "./modules/03-supporting-services"
  workloadName                        = var.workloadName
  environment                         = var.environment
  location                            = var.location
  resourceGroupName                   = module.spoke.spokeResourceGroupName
  aRecords                            = var.aRecords
  hubVnetId                           = module.hub.hubVnetId
  spokeVnetId                         = module.spoke.spokeVNetId
  spokePrivateEndpointSubnetId        = module.spoke.spokePrivateEndpointsSubnetId
  containerRegistryPullRoleAssignment = var.containerRegistryPullRoleAssignment
  keyVaultPullRoleAssignment          = var.keyVaultPullRoleAssignment
  vnetLinks = [
    {
      "name"                = module.spoke.spokeVNetName
      "vnetId"              = module.spoke.spokeVNetId
      "resourceGroupName"   = module.spoke.spokeResourceGroupName
      "registrationEnabled" = false
    },
    {
      "name"                = module.hub.hubVnetName
      "vnetId"              = module.hub.hubVnetId
      "resourceGroupName"   = module.hub.hubResourceGroupName
      "registrationEnabled" = false
  }]
  tags = var.tags

  # depends_on = [module.spoke]
}

module "containerAppsEnvironment" {
  source             = "./modules/04-container-apps-environment"
  workloadName       = var.workloadName
  environment        = var.environment
  location           = var.location
  resourceGroupName  = module.spoke.spokeResourceGroupName
  appInsightsName    = var.appInsightsName
  hubVnetId          = module.hub.hubVnetId
  spokeVnetId        = module.spoke.spokeVNetId
  spokeInfraSubnetId = module.spoke.spokeInfraSubnetId
  vnetLinks = [
    {
      "name"                = module.spoke.spokeVNetName
      "vnetId"              = module.spoke.spokeVNetId
      "resourceGroupName"   = module.spoke.spokeResourceGroupName
      "registrationEnabled" = false
    },
    {
      "name"                = module.hub.hubVnetName
      "vnetId"              = module.hub.hubVnetId
      "resourceGroupName"   = module.hub.hubResourceGroupName
      "registrationEnabled" = false
  }]
  tags = var.tags

  # depends_on = [module.supportingServices]
}

module "helloWorldApp" {
  source                                  = "./modules/05-hello-world-sample-app"
  location                                = var.location
  resourceGroupName                       = module.spoke.spokeResourceGroupName
  helloWorldContainerAppName              = var.helloWorldContainerAppName
  containerAppsEnvironmentId              = module.containerAppsEnvironment.containerAppsEnvironmentId
  containerRegistryUserAssignedIdentityId = module.supportingServices.containerRegistryUserAssignedIdentityId
  tags                                    = var.tags

  # depends_on = [module.containerAppsEnvironment]
}

module "applicationGateway" {
  source            = "./modules/06-application-gateway"
  workloadName      = var.workloadName
  environment       = var.environment
  location          = var.location
  resourceGroupName = module.spoke.spokeResourceGroupName
  # supportResourceGroupName        = module.spoke.spokeResourceGroupName
  keyVaultName                    = module.supportingServices.keyVaultName
  appGatewayCertificateKeyName    = var.appGatewayCertificateKeyName
  appGatewayFQDN                  = var.appGatewayFQDN
  appGatewayPrimaryBackendEndFQDN = module.helloWorldApp.helloWorldAppFQDN
  appGatewaySubnetId              = module.spoke.spokeApplicationGatewaySubnetId
  appGatewayLogAnalyticsId        = module.containerAppsEnvironment.logAnalyticsWorkspaceId
  appGatewayCertificatePath       = var.appGatewayCertificatePath
  tags                            = var.tags

  # depends_on = [module.helloWorldApp]
}