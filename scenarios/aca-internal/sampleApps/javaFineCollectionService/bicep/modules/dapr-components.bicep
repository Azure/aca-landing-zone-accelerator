@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of Dapr component for the secret store building block.')
param secretStoreComponentName string
@description('The name of Dapr component for the pub/sub building block.')
param pubSubComponentName string
@description('The name of Dapr component for the state store building block.')
param stateStoreComponentName string

@description('The name of the key vault resource.')
param keyVaultName string

@description('The name of the user managed identity used to access the keyvault.')
param userManagedIdentityName string

@description('The name of the service bus namespace.')
param serviceBusName string
@description('The name of the service bus topic.')
param serviceBusTopicName string
@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

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

@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string
@secure()
@description('The license key for Fine Collection Service.')
param fineLicenseKeySecretValue string

@description('The name of the secret containing service bus connection string.')
var serviceBusConnectionStringSecretName = 'service-bus-connection-string'
@description('The name of the secret containing Cosmos DB account URL.')
var cosmosDbAccountUrlSecretName = 'cosmos-db-account-url'
@description('Th name of the secret containing Azure Cosmos DB master key.')
var cosmosDbMasterKeySecretName = 'cosmos-db-master-key'

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userManagedIdentityName
}

resource serviceBusTopicAuthorizationRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' existing = {
  name: '${serviceBusName}/${serviceBusTopicName}/${serviceBusTopicAuthorizationRuleName}'
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

// TODO remove this when managed identities are used
resource serviceBusConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: serviceBusConnectionStringSecretName
  properties: {
    value: serviceBusTopicAuthorizationRule.listKeys().primaryConnectionString
  }
}

resource cosmosDbAccountUrlSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: cosmosDbAccountUrlSecretName
  properties: {
    value: cosmosDbAccount.properties.documentEndpoint
  }
}

resource cosmosDbMasterKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: cosmosDbMasterKeySecretName
  properties: {
    value: cosmosDbAccount.listKeys().primaryMasterKey
  }
}
// end of secrets to be removed

// License key secret used by Fine Collection Service
resource fineLicenseKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: fineLicenseKeySecretName
  properties: {
    value: fineLicenseKeySecretValue
  }
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
      fineCollectionServiceName
      trafficControlServiceName
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
        name: 'connectionString'
        secretRef: serviceBusConnectionStringSecretName
      }
    ]
    secretStoreComponent: secretstoreComponent.name
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
        secretRef: cosmosDbAccountUrlSecretName
      }
      {
        name: 'masterKey'
        secretRef: cosmosDbMasterKeySecretName
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
    secretStoreComponent: secretstoreComponent.name
    scopes: [
      trafficControlServiceName
    ]
  }
}
