

targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource Id of the container apps environment.')
param containerAppsEnvironmentId string

@description('The name of the service for the backend processor service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param backendProcessorServiceName string

// Key Vault
@description('The resource ID of the key vault to store the license key for the backend processor service.')
param keyVaultId string

@description('The name of the secret containing the SendGrid API key value for the Backend Background Processor Service.')
param sendGridKeySecretName string

@description('The SendGrid API key for for Backend Background Processor Service.')
@secure()
param sendGridKeySecretValue string

@description('The name of the secret containing the External Azure Storage Access key for the Backend Background Processor Service.')
param externalStorageKeySecretName string

@description('The Application Insights Instrumentation.')
@secure()
param appInsightsInstrumentationKey string

// Service Bus
@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

// External Storage
@description('The name of the external Azure Storage Account.')
param externalStorageAccountName string

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The image for the backend processor service.')
param backendProcessorServiceImage string

@description('The dapr port for the backend processor service.')
param backendProcessorPortNumber int


// ------------------
// VARIABLES
// ------------------

var keyVaultIdTokens = split(keyVaultId, '/')
var keyVaultSubscriptionId = keyVaultIdTokens[2]
var keyVaultResourceGroupName = keyVaultIdTokens[4]
var keyVaultName = keyVaultIdTokens[8]

// ------------------
// RESOURCES
// ------------------

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' existing = {
  name: serviceBusTopicName
  parent: serviceBusNamespace
}

resource serviceBusTopicAuthorizationRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' existing = {
  name: serviceBusTopicAuthorizationRuleName
  parent: serviceBusTopic
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: externalStorageAccountName
}

resource backendProcessorService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: backendProcessorServiceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
        '${containerRegistryUserAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
      dapr: {
        enabled: true
        appId: backendProcessorServiceName
        appProtocol: 'http'
        appPort: backendProcessorPortNumber
        logLevel: 'info'
        enableApiLogging: true
      }
      secrets: [
        {
          name: 'svcbus-connstring'
          value: serviceBusTopicAuthorizationRule.listKeys().primaryConnectionString
        }
        {
          name: 'appinsights-key'
          value: appInsightsInstrumentationKey
        }
      ]
      registries: !empty(containerRegistryName) ? [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: containerRegistryUserAssignedIdentityId
        }
      ] : []
    }
    template: {
      containers: [
        {
          name: backendProcessorServiceName
          image: backendProcessorServiceImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'SendGrid__IntegrationEnabled'
              value: empty(sendGridKeySecretValue) ? 'false' : 'true'
            }
            {
              name: 'ApplicationInsights__InstrumentationKey'
              secretRef: 'appinsights-key'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
        rules: [
          {
            name: 'topic-msgs-length'
            custom: {
              type: 'azure-servicebus'
              auth: [
                {
                  secretRef: 'svcbus-connstring'
                  triggerParameter: 'connection'
                }
              ]
              metadata: {
                namespace: serviceBusName
                subscriptionName: backendProcessorServiceName
                topicName: serviceBusTopicName
                messageCount: '10'
                connectionFromEnv: 'svcbus-connstring'
              }
            }
          }
        ]
      }
    }
  }
}


// Enable consume from servicebus using system managed identity.
resource backendProcessorService_sb_role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, backendProcessorServiceName, '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
  properties: {
    principalId: backendProcessorService.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0') // Azure Service Bus Data Receiver.
    principalType: 'ServicePrincipal'
  } 
  scope: serviceBusNamespace
}

// Invoke create secrets and assign role 'Azure Role Key Vault Secrets User' to the backend processor service
module backendProcessorKeySecret 'secrets/processor-backend-service-secrets.bicep' = {
  name: 'backendProcessorKeySecret-${uniqueString(resourceGroup().id)}'
  params: {
    keyVaultName: keyVaultName
    sendGridKeySecretName: sendGridKeySecretName
    sendGridKeySecretValue: sendGridKeySecretValue
    externalAzureStorageKeySecretName: externalStorageKeySecretName
    externalAzureStorageKeySecretValue: storageAccount.listKeys().keys[0].value
    backendProcessorServicePrincipalId: backendProcessorService.identity.principalId
  }
  scope: resourceGroup(keyVaultSubscriptionId, keyVaultResourceGroupName)
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the backend processor service.')
output backendProcessorServiceContainerAppName string = backendProcessorService.name
