targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The name of the Key Vault.')
param keyVaultName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('The name of the private endpoint to be created for Key Vault.')
param keyVaultPrivateEndpointName string




@description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticEventHubName string = ''


@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.')
@allowed([
  'allLogs'
  'AuditEvent'
  'AzurePolicyEvaluationDetails'
])
param diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed. If left empty, it defaults to "<resourceName>-diagnosticSettings".')
param diagnosticSettingsName string = ''

// ------------------
// VARIABLES
// ------------------

var privateDnsZoneNames = 'privatelink.vaultcore.azure.net'
var keyVaultResourceName = 'vault'

var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]

var spokeVNetIdTokens = split(spokeVNetId, '/')
var spokeSubscriptionId = spokeVNetIdTokens[2]
var spokeResourceGroupName = spokeVNetIdTokens[4]
var spokeVNetName = spokeVNetIdTokens[8]


var spokeVNetLinks = [
  {
    vnetName: spokeVNetName
    vnetId: vnetSpoke.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var diagnosticsLogsSpecified = [for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs'): {
  category: category
  enabled: true  
}]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs') ? [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
] : diagnosticsLogsSpecified

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]


// ------------------
// RESOURCES
// ------------------

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(spokeSubscriptionId, spokeResourceGroupName)  
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnetSpoke
  name: spokePrivateEndpointSubnetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location  
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    enablePurgeProtection: null  // It seems that you cannot set it to False even the first time. workaround is not to set it at all: https://github.com/Azure/bicep/issues/5223
    publicNetworkAccess: 'Disabled'
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
  }
}

resource keyVault_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: !empty(diagnosticSettingsName) ? diagnosticSettingsName : '${keyVaultName}-diagnosticSettings'
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: keyVault
}


module keyVaultNetwork '../../../../../shared/bicep/network/private-networking.bicep' = {
  name: 'keyVaultNetwork-${uniqueString(keyVault.id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneNames
    azServiceId: keyVault.id
    privateEndpointName: keyVaultPrivateEndpointName
    privateEndpointSubResourceName: keyVaultResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
    vnetHubResourceId: hubVNetId
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the key vault.')
output keyVaultId string = keyVault.id

@description('The name of the key vault.')
output keyVaultName string = keyVault.name
