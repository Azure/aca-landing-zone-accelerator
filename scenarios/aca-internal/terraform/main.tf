module "hub" {
  source                                     = "./modules/01-hub"
  subscription_id                            = var.subscription_id
  workloadName                               = var.workloadName
  environment                                = var.environment
  hubResourceGroupName                       = var.hubResourceGroupName
  location                                   = var.location
  vnetAddressPrefixes                        = var.hubVnetAddressPrefixes
  enableBastion                              = var.enableBastion
  bastionSubnetAddressPrefixes               = var.bastionSubnetAddressPrefixes
  gatewaySubnetAddressPrefix                 = var.gatewaySubnetAddressPrefix
  azureFirewallSubnetAddressPrefix           = var.azureFirewallSubnetAddressPrefix
  azureFirewallSubnetManagementAddressPrefix = var.azureFirewallSubnetManagementAddressPrefix
  infraSubnetAddressPrefix                   = var.infraSubnetAddressPrefix
  tags                                       = var.tags
}

module "spoke" {
  source                                = "./modules/02-spoke"
  subscription_id                       = var.subscription_id
  workloadName                          = var.workloadName
  environment                           = var.environment
  spokeResourceGroupName                = var.spokeResourceGroupName
  location                              = var.location
  vnetAddressPrefixes                   = var.spokeVnetAddressPrefixes
  infraSubnetAddressPrefix              = var.infraSubnetAddressPrefix
  infraSubnetName                       = var.infraSubnetName
  privateEndpointsSubnetAddressPrefix   = var.privateEndpointsSubnetAddressPrefix
  applicationGatewaySubnetAddressPrefix = var.applicationGatewaySubnetAddressPrefix
  hubVnetId                             = module.hub.hubVnetId
  vmSize                                = var.vmSize
  vmAdminUsername                       = var.vmAdminUsername
  vmAdminPassword                       = var.vmAdminPassword
  vmLinuxSshAuthorizedKeys              = var.vmLinuxSshAuthorizedKeys
  vmLinuxAuthenticationType             = var.vmLinuxAuthenticationType
  vmJumpboxOSType                       = var.vmJumpboxOSType
  jumpboxSubnetAddressPrefix            = var.vmJumpBoxSubnetAddressPrefix
  firewallPrivateIp                     = module.hub.firewallPrivateIp
  tags                                  = var.tags
}

module "supportingServices" {
  source                              = "./modules/03-supporting-services"
  subscription_id                     = var.subscription_id
  workloadName                        = var.workloadName
  environment                         = var.environment
  location                            = var.location
  spokeResourceGroupName              = module.spoke.spokeResourceGroupName
  aRecords                            = var.aRecords
  hubResourceGroupName                = module.hub.hubResourceGroupName
  hubVnetId                           = module.hub.hubVnetId
  spokeVnetId                         = module.spoke.spokeVNetId
  spokePrivateEndpointSubnetId        = module.spoke.spokePrivateEndpointsSubnetId
  containerRegistryPullRoleAssignment = var.containerRegistryPullRoleAssignment
  keyVaultPullRoleAssignment          = var.keyVaultPullRoleAssignment
  clientIP                            = var.clientIP
  logAnalyticsWorkspaceId             = module.spoke.logAnalyticsWorkspaceId
  supportingResourceGroupName         = var.supportingResourceGroupName

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
}

module "containerAppsEnvironment" {
  source                  = "./modules/04-container-apps-environment"
  subscription_id         = var.subscription_id
  workloadName            = var.workloadName
  environment             = var.environment
  location                = var.location
  spokeResourceGroupName  = module.spoke.spokeResourceGroupName
  hubResourceGroupName    = module.hub.hubResourceGroupName
  appInsightsName         = var.appInsightsName
  hubVnetId               = module.hub.hubVnetId
  spokeVnetId             = module.spoke.spokeVNetId
  spokeInfraSubnetId      = module.spoke.spokeInfraSubnetId
  logAnalyticsWorkspaceId = module.spoke.logAnalyticsWorkspaceId
  workloadProfiles        = var.workloadProfiles
  tags                    = var.tags

  vnetLinks = [
    {
      name                = module.spoke.spokeVNetName
      vnetId              = module.spoke.spokeVNetId
      resourceGroupName   = module.spoke.spokeResourceGroupName
      registrationEnabled = false
    },
    {
      name                = module.hub.hubVnetName
      vnetId              = module.hub.hubVnetId
      resourceGroupName   = module.hub.hubResourceGroupName
      registrationEnabled = false
  }]
}

module "helloWorldApp" {
  source                                  = "./modules/05-hello-world-sample-app"
  subscription_id                         = var.subscription_id
  deployApp                               = var.deployHelloWorldSample
  resourceGroupName                       = module.spoke.spokeResourceGroupName
  helloWorldContainerAppName              = var.helloWorldContainerAppName
  containerAppsEnvironmentId              = module.containerAppsEnvironment.containerAppsEnvironmentId
  containerRegistryUserAssignedIdentityId = module.supportingServices.containerRegistryUserAssignedIdentityId
  workloadProfileName                     = var.workloadProfiles != [] ? var.workloadProfiles.0.name : "Consumption"
  tags                                    = var.tags
}

# If you would like to deploy an Application Gateway and have provided your IP address for KeyVault access, leave this module uncommented
# If you would like to keep your KeyVault private, comment out this module
module "applicationGateway" {
  source                          = "./modules/06-application-gateway"
  subscription_id                 = var.subscription_id
  workloadName                    = var.workloadName
  environment                     = var.environment
  location                        = var.location
  resourceGroupName               = module.spoke.spokeResourceGroupName
  keyVaultName                    = module.supportingServices.keyVaultName
  appGatewayCertificateKeyName    = var.appGatewayCertificateKeyName
  appGatewayFQDN                  = var.appGatewayFQDN
  appGatewayPrimaryBackendEndFQDN = module.helloWorldApp.helloWorldAppFQDN
  appGatewaySubnetId              = module.spoke.spokeApplicationGatewaySubnetId
  appGatewayLogAnalyticsId        = module.spoke.logAnalyticsWorkspaceId
  appGatewayCertificatePath       = var.appGatewayCertificatePath
  logAnalyticsWorkspaceId         = module.spoke.logAnalyticsWorkspaceId
  tags                            = var.tags
}
