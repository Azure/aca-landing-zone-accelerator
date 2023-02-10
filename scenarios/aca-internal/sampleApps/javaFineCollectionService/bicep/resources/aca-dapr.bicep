@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the service bus namespace.')
param serviceBusName string
@description('The name of Cosmos DB resource.')
param cosmosDbName string
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string
@description('The name of user assigned identity used by the access cosmosdb')
param acaIdentityName string

@description('The name of provisioned keyvault instance')
param keyVaultName string

//should be a var instead of a param. 
param location string = resourceGroup().location

@description('The name of the service for the fine collection service.')
var fineCollectionServiceName  = 'fine-collection-service'
@description('The name of the service for the traffic control service.')
var trafficControlServiceName  = 'traffic-control-service'
@description('The name of Dapr component for the pub/sub building block.')
var pubSubComponentName  = 'pubsub'
@description('The name of Dapr component for the state store building block.')
var stateStoreComponentName  = 'statestore'
@description('The name of Dapr component for the pub/sub building block.')
var secretStoreComponentName  = 'secretstore'

var fineLicenseKeySecretValue = 'HX783-5PN1G-CRJ4A-K2L7V'

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}



resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: acaIdentityName
  location: location
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}


resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: pubSubComponentName
  parent: containerAppsEnvironment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name:'namespaceName'
        value:'${serviceBusName}.servicebus.windows.net'
      }
      {
        name: 'azureClientId'
        value: acaIdentity.properties.clientId
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
       
    ]
    metadata: [
      {
        name: 'url'
        secretRef: 'cosmos-db-account-url'
      }
      {
       name: 'azureClientId'
       value: acaIdentity.properties.clientId
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

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
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
        value: keyVault.name
      }
      {
        name: 'azureClientId'
        value: acaIdentity.properties.clientId
      }
    ]
    scopes: [
      'fine-collection-service'
      'traffic-control-service'
    ]
  }
}

resource fineLicenseKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'license-key'
  properties: {
    value: fineLicenseKeySecretValue
  }
}
