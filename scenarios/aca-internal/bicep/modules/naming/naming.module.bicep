targetScope = 'resourceGroup'

@description('Location for all Resources.')
param location string

param workloadName string

param environmentName string

@description('a unique ID that can be appended (or prepended) in azure resource names that require some kind of uniqueness')
param uniqueId string


var naming = json(loadTextContent('./naming-rules.jsonc'))

// get arbitary 5 first characters (instead of something like 5yj4yjf5mbg72), to save string length. This may cause non uniqueness
var uniqueIdShort = substring(uniqueId, 0, 5)
var resourceTypeToken = 'RES_TYPE'

// Define and adhere to a naming convention, such as: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
var namingBase = '${resourceTypeToken}-${workloadName}-${environmentName}-${naming.regionAbbreviations[toLower(location)]}'
var namingBaseUnique = '${resourceTypeToken}-${workloadName}-${uniqueIdShort}-${environmentName}-${naming.regionAbbreviations[toLower(location)]}'

var resourceNames = {
  spokeVNet: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualNetwork)
  hubVNet: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualNetwork)
  applicationGateway: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)
  applicationGatewayPublicIp: '${naming.resourceTypeAbbreviations.publicIpAddress}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)}'
  applicationGatewayUserAssignedIdentity: '${naming.resourceTypeAbbreviations.managedIdentity}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationGateway)}'
  applicationInsights: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.applicationInsights)
  bastion: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)
  bastionNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)}'
  bastionPublicIp: '${naming.resourceTypeAbbreviations.publicIpAddress}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.bastion)}'
  containerAppsEnvironment: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.containerAppsEnvironment)
  containerRegistry: take ( toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) ), 50 )
  containerRegistryPrivateEndpoint:  '${naming.resourceTypeAbbreviations.privateEndpoint}-${toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) )}'
  containerRegistryUserAssignedIdentity:  '${naming.resourceTypeAbbreviations.managedIdentity}-${toLower( replace ( replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.containerRegistry), '-', '' ) )}'
  cosmosDbNoSql: toLower( take(replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.cosmosDbNoSql), 44) )
  cosmosDbNoSqlPe: '${naming.resourceTypeAbbreviations.privateEndpoint}-${toLower( take(replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.cosmosDbNoSql), 44) )}'
  keyVault: take ( replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault ), 24 )
  keyVaultPrivateEndpoint:  '${naming.resourceTypeAbbreviations.privateEndpoint}-${replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault )}'
  keyVaultUserAssignedIdentity:  '${naming.resourceTypeAbbreviations.managedIdentity}-${replace ( namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.keyVault )}'
  logAnalyticsWorkspace: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.logAnalyticsWorkspace)
  serviceBus: replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.serviceBus)
  serviceBusPe: '${naming.resourceTypeAbbreviations.privateEndpoint}-${replace(namingBaseUnique, resourceTypeToken, naming.resourceTypeAbbreviations.serviceBus)}'
  vmJumpBox: replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)
  vmJumpBoxNsg: '${naming.resourceTypeAbbreviations.networkSecurityGroup}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)}'
  vmJumpBoxNic: '${naming.resourceTypeAbbreviations.networkInterface}-${replace(namingBase, resourceTypeToken, naming.resourceTypeAbbreviations.virtualMachine)}'
}

output resourcesNames object = resourceNames
