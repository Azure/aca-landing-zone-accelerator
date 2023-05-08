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

@description('The name of the external Azure Storage Account.')
param storageAccountName string

@description('The name of the external Queue in Azure Storage.')
param externalTasksQueueName string

@description('The name of the external blob container in Azure Storage.')
param externalTasksContainerBlobName string

@description('The name of the secret containing the External Azure Storage Access key.')
param externalStorageKeySecretName string

@description('The name of the Send Grid Email From.')
param sendGridEmailFrom string

@description('The name of the Send Grid Email From Name.')
param sendGridEmailFromName string

@description('The name of the secret containing the SendGrid API key value.')
param sendGridKeySecretName string

@description('The cron settings for scheduled job.')
param scheduledJobCron string 

@description('The name of the service for the backend api service. The name is used as Dapr App ID.')
param backendApiServiceName string

@description('The name of the service for the backend processor service. The name is used as Dapr App ID and as the name of service bus topic subscription.')
param backendProcessorServiceName string

// ------------------
// RESOURCES
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

//Secret Store Component
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
      backendApiServiceName
      backendProcessorServiceName
    ]
  }
}

//Cosmos DB State Store Component
resource statestoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'statestore'
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
    ]
    scopes: [
      backendApiServiceName
    ]
  }
}

//PubSub service bus Component
resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'dapr-pubsub-servicebus'
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
        name: 'consumerID'
        value: backendProcessorServiceName
      }
    ]
    scopes: [
      backendApiServiceName
      backendProcessorServiceName
    ]
  }
}

//Scheduled Tasks Manager Component
resource scheduledtasksmanagerDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'scheduledtasksmanager'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'bindings.cron'
    version: 'v1'
    metadata: [
      {
        name: 'schedule'
        value: scheduledJobCron
      }
    ]
    scopes: [
      backendProcessorServiceName
    ]
  }
}

//External tasks manager Component (Storage Queue)
resource externaltasksmanagerDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'externaltasksmanager'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'bindings.azure.storagequeues'
    version: 'v1'
    secretStoreComponent: secretStoreComponentName
    metadata: [
      {
        name: 'storageAccount'
        value: storageAccountName
      }
      {
        name: 'queue'
        value: externalTasksQueueName
      }
      {
        name: 'decodeBase64'
        value: 'true'
      }
      {
        name: 'route'
        value: '/externaltasksprocessor/process'
      }
      {
        name: 'storageAccessKey'
        secretRef: externalStorageKeySecretName
      }
    ]
    scopes: [
      backendProcessorServiceName
    ]
  }
  dependsOn: [
    secretstoreComponent
  ]
}

//External tasks blob store Component (Blob Store)
resource externaltasksblobstoreDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'externaltasksblobstore'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'bindings.azure.blobstorage'
    version: 'v1'
    secretStoreComponent: secretStoreComponentName
    metadata: [
      {
        name: 'storageAccount'
        value: storageAccountName
      }
      {
        name: 'container'
        value: externalTasksContainerBlobName
      }
      {
        name: 'decodeBase64'
        value: 'false'
      }
      {
        name: 'publicAccessLevel'
        value: 'none'
      }
      {
        name: 'storageAccessKey'
        secretRef: externalStorageKeySecretName
      }
    ]
    scopes: [
      backendProcessorServiceName
    ]
  }
  dependsOn: [
    secretstoreComponent
  ]
}

//SendGrid outbound Component
resource sendgridDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'sendgrid'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'bindings.twilio.sendgrid'
    version: 'v1'
    secretStoreComponent: secretStoreComponentName
    metadata: [
      {
        name: 'emailFrom'
        value: sendGridEmailFrom
      }
      {
        name: 'emailFromName'
        value: sendGridEmailFromName
      }
      {
        name: 'apiKey'
        secretRef: sendGridKeySecretName
      }
    ]
    scopes: [
      backendProcessorServiceName
    ]
  }
  dependsOn:[
    secretstoreComponent
  ]
}
