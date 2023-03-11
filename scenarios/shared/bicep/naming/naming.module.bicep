// ------------------
//    PARAMETERS
// ------------------

@description('Location for all Resources.')
param location string

@description('a unique ID that can be appended (or prepended) in azure resource names that require some kind of uniqueness')
param uniqueId string

// ------------------
// VARIABLES
// ------------------

var naming = json(loadTextContent('./naming-rules.jsonc'))

// get arbitary 5 first characters (instead of something like 5yj4yjf5mbg72), to save string length. This may cause non uniqueness
var uniqueIdShort = substring(uniqueId, 0, 5)
var resourceTypeToken = 'RES_TYPE'

// Define and adhere to a naming convention, such as: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
var namingBase = '${resourceTypeToken}-${naming.workloadName}-${naming.environment}-${naming.regionAbbreviations[toLower(location)]}'
// Used for hub resources - should be shared across different workloads
var namingBaseNoWorkloadName = '${resourceTypeToken}-${naming.environment}-${naming.regionAbbreviations[toLower(location)]}'
var namingBaseUnique = '${resourceTypeToken}-${naming.workloadName}-${uniqueIdShort}-${naming.environment}-${naming.regionAbbreviations[toLower(location)]}'

var resourceNames = {
  vnetSpoke: '${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualNetwork)}-spoke'
  vnetHub: '${replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.virtualNetwork)}-hub'
  applicationGateway: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)
  applicationGatewayPip: '${naming.resourceTypeAbbreviations.publicIpAddress}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)}'
  applicationGatewayUserAssignedIdentity: '${naming.resourceTypeAbbreviations.managedIdentity}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)}-KeyVaultSecretUser'
  applicationInsights: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationInsights)
  bastion: replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)
  bastionNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)}'
  bastionPip: '${naming.resourceTypeAbbreviations.publicIpAddress}-${replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)}'
  containerAppsEnvironment: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.containerAppsEnvironment)
  containerAppsEnvironmentNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.containerAppsEnvironment)}'
  containerRegistry: take ( toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) ), 50 )
  containerRegistryPep:  '${naming.resourceTypeAbbreviations.privateEndpoint}-${toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) )}'
  containerRegistryUserAssignedIdentity:  '${naming.resourceTypeAbbreviations.managedIdentity}-${toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) )}-AcrPull'
  cosmosDbNoSql: toLower( take(replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.cosmosDbNoSql), 44) )
  cosmosDbNoSqlPep: '${naming.resourceTypeAbbreviations.privateEndpoint}-${toLower( take(replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.cosmosDbNoSql), 44) )}'
  keyVault: take ( replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault ), 24 )
  keyVaultPep:  '${naming.resourceTypeAbbreviations.privateEndpoint}-${replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault )}'
  keyVaultUserAssignedIdentity:  '${naming.resourceTypeAbbreviations.managedIdentity}-${replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault )}-KeyVaultReader'
  logAnalyticsWorkspace: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.logAnalyticsWorkspace)
  serviceBus: replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.serviceBus)
  serviceBusPep: '${naming.resourceTypeAbbreviations.privateEndpoint}-${replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.serviceBus)}'
  vmJumpBox: replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)
  vmJumpBoxNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)}'
  vmJumpBoxNic: '${naming.resourceTypeAbbreviations.networkInterface}-${replace(namingBaseNoWorkloadName, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)}'
}

output resourcesNames object = resourceNames
