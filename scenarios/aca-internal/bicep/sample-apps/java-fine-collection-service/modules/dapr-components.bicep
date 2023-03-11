targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of Dapr component for the secret store building block.')
// We disable lint of this line as it is not a secret but the name of the Dapr component
#disable-next-line secure-secrets-in-params
param secretStoreComponentName string

@description('The name of Dapr component for the pub/sub building block.')
param pubSubComponentName string

@description('The name of Dapr component for the state store building block.')
param stateStoreComponentName string

// todo replace with key vault resource id
@description('The name of the key vault resource.')
param keyVaultName string

@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string

@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string

@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string

@description('The name of the service for the traffic control service.')
param trafficControlServiceName string

// ------------------
// RESOURCES
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

resource secretstoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: secretStoreComponentName
  parent: containerAppsEnvironment
  properties: {
    componentType: 'secretstores.azure.keyvault'
    version: 'v1'
    metadata: [
      {
        name: 'vaultName'
        value: keyVaultName
      }
    ]
    scopes: [
      fineCollectionServiceName
    ]
  }
}

// Secret store is only supported in the preview version of the Dapr components API
resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: pubSubComponentName
  parent: containerAppsEnvironment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    secrets: [
    ]
    metadata: [
      {
        name: 'namespaceName'
        value: '${serviceBusName}.servicebus.windows.net'
      }
      {
        name: 'disableEntityManagement'
        value: 'true'
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
    ]
    metadata: [
      {
        name: 'url'
        value: cosmosDbAccount.properties.documentEndpoint
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
