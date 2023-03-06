@description('Location for all Resources.')
param location string

@description('a unique ID that can be appended (or prepended) in azure resource names that require some kind of uniqueness')
param uniqueId string


var naming = json(loadTextContent('./naming-rules.jsonc'))

// get arbitary 5 first characters (instead of something like 5yj4yjf5mbg72), to save string length. This may cause non uniqueness
var uniqueIdShort = substring(uniqueId, 0, 5)
var resourceTypeToken = 'RES_TYPE'

// Define and adhere to a naming convention, such as: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
var namingBase = '${resourceTypeToken}-${naming.workloadName}-${naming.environment}-${naming.regionAbbreviations[toLower(location)]}'
var namingBaseUnique = '${resourceTypeToken}-${uniqueIdShort}-${naming.workloadName}-${naming.environment}-${naming.regionAbbreviations[toLower(location)]}'

var resourceNames = {
  vnetSpoke: '${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualNetwork)}-spoke'
  vnetHub: '${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualNetwork)}-hub'
  applicationGateway: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)
  applicationGatewayPip: '${naming.resourceTypeAbbreviations.publicIpAddress}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)}'
  applicationGatewayId: '${naming.resourceTypeAbbreviations.managedIdentity}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)}'
  appInsights: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationInsights)
  bastion: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)
  bastionNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)}'
  bastionPip: '${naming.resourceTypeAbbreviations.publicIpAddress}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)}'
  containerAppsEnvironment: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.containerAppsEnvironment)
  containerRegistry: take ( toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) ), 50 )
  containerRegistryPe:  '${naming.resourceTypeAbbreviations.privateEndpoint}-${toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) )}'
  containerRegistryId:  '${naming.resourceTypeAbbreviations.managedIdentity}-${toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) )}'
  cosmosDbNoSql: toLower( take(replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.cosmosDbNoSql), 44) )
  cosmosDbNoSqlPe: '${naming.resourceTypeAbbreviations.privateEndpoint}-${toLower( take(replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.cosmosDbNoSql), 44) )}'
  keyVault: take ( replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault ), 24 )
  keyVaultPe:  '${naming.resourceTypeAbbreviations.privateEndpoint}-${replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault )}'
  keyVaultId:  '${naming.resourceTypeAbbreviations.managedIdentity}-${replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault )}'
  logAnalyticsWorkspace: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.logAnalyticsWorkspace)
  serviceBus: replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.serviceBus)
  serviceBusPe: '${naming.resourceTypeAbbreviations.privateEndpoint}-${replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.serviceBus)}'
  vmJumpBox: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)
  vmJumpBoxNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)}'
  vmJumpBoxNic: '${naming.resourceTypeAbbreviations.networkInterface}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)}'


  // Storage account names (and other resources) have strict naming rules. You may ignore here, but sanitize as much as possible in the resource module
  //storageAppOne: replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.storageAccount)
  //or without if you decide not to have module naming sanitization, you can add some basic rules here:....
  storageAppOne: take ( toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.storageAccount), '-', '' ) ), 24 )
}

output resourcesNames object = resourceNames
