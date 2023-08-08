locals {
  namingBase               = "${var.resourceTypeToken}-${var.workloadName}-${var.environment}-${var.regionAbbreviations["${var.location}"]}"
  namingBaseUnique         = "${var.resourceTypeToken}-${var.workloadName}-${var.uniqueId}-${var.environment}-${var.regionAbbreviations["${var.location}"]}"
  namingBaseNoWorkloadName = "${var.resourceTypeToken}-${var.environment}-${var.regionAbbreviations["${var.location}"]}"

  resourceNames = {
    vnetSpoke                              = "${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.virtualNetwork)}-spoke"
    vnetHub                                = "${replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.virtualNetwork)}-hub"
    applicationGateway                     = replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.applicationGateway)
    applicationGatewayNsg                  = "${var.resourceTypeAbbreviations.networkSecurityGroup}-${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.applicationGateway)}"
    applicationGatewayPip                  = "${var.resourceTypeAbbreviations.publicIpAddress}-${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.applicationGateway)}"
    applicationGatewayUserAssignedIdentity = "${var.resourceTypeAbbreviations.managedIdentity}-${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.applicationGateway)}-KeyVaultSecretUser"
    applicationInsights                    = replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.applicationInsights)
    bastion                                = replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.bastion)
    bastionNsg                             = "${var.resourceTypeAbbreviations.networkSecurityGroup}-${replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.bastion)}"
    bastionPip                             = "${var.resourceTypeAbbreviations.publicIpAddress}-${replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.bastion)}"
    containerAppsEnvironment               = replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.containerAppsEnvironment)
    containerAppsEnvironmentNsg            = "${var.resourceTypeAbbreviations.networkSecurityGroup}-${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.containerAppsEnvironment)}"
    containerRegistry                      = substr(lower(replace(replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.containerRegistry), "-", "")), 0, 50)
    containerRegistryPep                   = "${var.resourceTypeAbbreviations.privateEndpoint}-${lower(replace(replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.containerRegistry), "-", ""))}"
    containerRegistryUserAssignedIdentity  = "${var.resourceTypeAbbreviations.managedIdentity}-${lower(replace(replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.containerRegistry), "-", ""))}-AcrPull"
    cosmosDbNoSql                          = lower(substr(replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.cosmosDbNoSql), 0, 44))
    cosmosDbNoSqlPep                       = "${var.resourceTypeAbbreviations.privateEndpoint}-${lower(substr(replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.cosmosDbNoSql), 0, 44))}"
    frontDoorProfile                       = replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.frontDoor)
    keyVault                               = substr(replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.keyVault), 0, 24)
    keyVaultPep                            = "${var.resourceTypeAbbreviations.privateEndpoint}-${replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.keyVault)}"
    keyVaultUserAssignedIdentity           = "${var.resourceTypeAbbreviations.managedIdentity}-${replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.keyVault)}-KeyVaultReader"
    logAnalyticsWorkspace                  = replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.logAnalyticsWorkspace)
    privateEndpointsNsg                    = "${var.resourceTypeAbbreviations.networkSecurityGroup}-${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.privateEndpoint)}"
    privateLinkServiceName                 = "${var.resourceTypeAbbreviations.privateLinkService}-${replace(local.namingBase, var.resourceTypeToken, var.resourceTypeAbbreviations.frontDoor)}"
    rgHubName                              = "${var.resourceTypeAbbreviations.resourceGroup}-${var.workloadName}-hub-${var.environment}-${var.regionAbbreviations[lower(var.location)]}"
    rgSpokeName                            = "${var.resourceTypeAbbreviations.resourceGroup}-${var.workloadName}-spoke-${var.environment}-${var.regionAbbreviations[lower(var.location)]}"
    serviceBus                             = replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.serviceBus)
    serviceBusPep                          = "${var.resourceTypeAbbreviations.privateEndpoint}-${replace(local.namingBaseUnique, var.resourceTypeToken, var.resourceTypeAbbreviations.serviceBus)}"
    vmJumpBox                              = replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.virtualMachine)
    vmJumpBoxNsg                           = "${var.resourceTypeAbbreviations.networkSecurityGroup}-${replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.virtualMachine)}"
    vmJumpBoxNic                           = "${var.resourceTypeAbbreviations.networkInterface}-${replace(local.namingBaseNoWorkloadName, var.resourceTypeToken, var.resourceTypeAbbreviations.virtualMachine)}"
  }
}
