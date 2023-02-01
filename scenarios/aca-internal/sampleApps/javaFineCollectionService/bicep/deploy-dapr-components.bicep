param pubSubComponentName string = 'pubsub'
param stateStoreComponentName string = 'statestore'

param containerAppsEnvironmentName string

param serviceBusConnectionString string

param cosmosDbAccountUrl string
param cosmosDbMasterKey string
param cosmosDbDatabaseName string
param cosmosDbCollectionName string

@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string = 'fine-collection-service'
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string = 'traffic-control-service'

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
} 

resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: pubSubComponentName
  parent: containerAppsEnvironment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        value: serviceBusConnectionString
      }
    ]
    scopes: [
      fineCollectionServiceName
      trafficControlServiceName
    ]
  }
}

resource statestoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: stateStoreComponentName
  parent: containerAppsEnvironment
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    metadata: [
      {
        name: 'url'
        value: cosmosDbAccountUrl
      }
      {
        name: 'masterKey'
        value: cosmosDbMasterKey
      }
      {
        name: 'database'
        value: cosmosDbDatabaseName
      }
      {
        name: 'collection'
        value: cosmosDbCollectionName
      }
      {
        name: 'actorStateStore'
        value: 'true'
      }
    ]
    scopes: [
      trafficControlServiceName
    ]
  }
}
