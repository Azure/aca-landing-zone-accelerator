@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of Dapr component for the pub/sub building block.')
param pubSubComponentName string = 'pubsub'
@description('The name of Dapr component for the state store building block.')
param stateStoreComponentName string = 'statestore'

@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string = 'fine-collection-service'
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string = 'traffic-control-service'

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource serviceBusTopicAuthorizationRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' existing = {
  name: '${serviceBusName}/test/TestTopicSharedAccessKey'
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: pubSubComponentName
  parent: containerAppsEnvironment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    secrets: [
      {
        name: 'service-bus-connection-string'
        value: serviceBusTopicAuthorizationRule.listKeys().primaryConnectionString
      }
    ]
    metadata: [
      {
        name: 'connectionString'
        secretRef: 'service-bus-connection-string'
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
    secrets: [
      {
        name: 'cosmos-db-account-url'
        value: cosmosDbAccount.properties.documentEndpoint
      }
      {
        name: 'cosmos-db-master-key'
        value: cosmosDbAccount.listKeys().primaryMasterKey
      }
    ]
    metadata: [
      {
        name: 'url'
        secretRef: 'cosmos-db-account-url'
      }
      {
        name: 'masterKey'
        secretRef: 'cosmos-db-master-key'
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
