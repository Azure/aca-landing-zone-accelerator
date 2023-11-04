// Parameters
@description('Specifies the name of the Service Bus namespace.')
param name string

@description('Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.')
param zoneRedundant bool = true

@description('Specifies the name of Service Bus namespace SKU.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param skuName string = 'Standard'

@description('Specifies the messaging units for the Service Bus namespace. For Premium tier, capacity are 1,2 and 4.')
param capacity int = 1

@description('Specifies the name of the Service Bus queue.')
param queueNames array = []

@description('Specifies the name of the Service Bus topic.')
param topicNames array = []

@description('Specifies the lock duration of the queue.')
param lockDuration string = 'PT5M'

@description('Specifies the maximum delivery count of the queue.')
param maxDeliveryCount int = 10

@description('Specifies whether duplication is enabled on the queue.')
param requiresDuplicateDetection bool = false

@description('Specifies whether session is enabled on the queue.')
param requiresSession bool = false

@description('Specifies whether dead lettering is enabled on the queue.')
param deadLetteringOnMessageExpiration bool = false

@description('Specifies the duplicate detection history time of the queue.')
param duplicateDetectionHistoryTimeWindow string = 'PT10M'

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the workspace data retention in days.')
param retentionInDays int = 0

@description('Specifies whether the namespace is accesiible from internet.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var logCategories = [
  'OperationalLogs'
  'VNetAndIPFilteringLogs'
  'RuntimeAuditLogs'
  'ApplicationMetricsLogs'
]
var metricCategories = [
  'AllMetrics'
]
var logs = [for category in logCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: false
    days: retentionInDays
  }
}]
var metrics = [for category in metricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: false
    days: retentionInDays
  }
}]

var serviceBusEndpoint = '${namespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, namespace.apiVersion).primaryConnectionString

// Resources
resource namespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    zoneRedundant: skuName == 'Premium' ? zoneRedundant : false
    disableLocalAuth: publicNetworkAccess == 'Disabled' ? false : true
    publicNetworkAccess: publicNetworkAccess
  }
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [for queueName in queueNames: {
  parent: namespace
  name: queueName
  properties: {
    lockDuration: lockDuration
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: requiresDuplicateDetection
    requiresSession: requiresSession
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    maxDeliveryCount: maxDeliveryCount
  }
}]

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = [for topicName in topicNames: {
  parent: namespace
  name: topicName
  properties: {
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: requiresDuplicateDetection
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: true
    enablePartitioning: true
  }
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: namespace
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

// Outputs
output id string = namespace.id
output name string = namespace.name
output connectionString string = serviceBusConnectionString
output queues array = [for (queueName, i) in queueNames: {
  name: name
  id: queue[i].id
}]
output topics array = [for (topicName, i) in topicNames: {
  name: name
  id: topic[i].id
}]
