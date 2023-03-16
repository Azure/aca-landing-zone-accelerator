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

@description('The name of the service for the fine collection service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param fineCollectionServiceName string

@description('The name of the service for the vehicle registration service. The name is use as Dapr App ID and for service-to-service invocation by fine collection service.')
param vehicleRegistrationServiceDaprAppId string

// Key Vault
@description('The resource ID of the key vault to store the license key for the fine collection service.')
param keyVaultId string

@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string

@secure()
@description('The license key for Fine Collection Service.')
param fineLicenseKeySecretValue string

// Service Bus
@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The image for the fine collection service.')
param fineCollectionServiceImage string

// ------------------
// VARIABLES
// ------------------

var keyVaultIdTokens = split(keyVaultId, '/')
var keyVaultSubscriptionId = keyVaultIdTokens[2]
var keyVaultResourceGroupName = keyVaultIdTokens[4]
var keyVaultName = keyVaultIdTokens[8]

var containerAppName = 'ca-${fineCollectionServiceName}'

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

resource serviceBusTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' existing = {
  name: fineCollectionServiceName
  parent: serviceBusTopic
}

resource fineCollectionService 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
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
        appId: fineCollectionServiceName
        appProtocol: 'http'
        appPort: 6001
      }
      secrets: [
        {
          name: 'service-bus-connection-string'
          value: serviceBusTopicAuthorizationRule.listKeys().primaryConnectionString
        }
      ]
      registries: !empty(containerRegistryName) ?[
        {
          server: !empty(containerRegistryName) ? '${containerRegistryName}.azurecr.io' : ''
          identity: containerRegistryUserAssignedIdentityId
        }
      ] : []
    }
    template: {
      containers: [
        {
          name: fineCollectionServiceName
          image: fineCollectionServiceImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'VEHICLE_REGISTRATION_SERVICE'
              value: vehicleRegistrationServiceDaprAppId
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'service-bus-test-topic'
            custom: {
              type: 'azure-servicebus'
              auth: [
                {
                  secretRef: 'service-bus-connection-string'
                  triggerParameter: 'connection'
                }
              ]
              metadata: {
                subscriptionName: fineCollectionServiceName
                topicName: serviceBusTopicName
                messageCount: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// Enable consume from servicebus using app managed identity.
resource serviceBusDataReceiverRoleAssignment  'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, fineCollectionServiceName, '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
  properties: {
    principalId: fineCollectionService.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0') // Azure Service Bus Data Receiver.
    principalType: 'ServicePrincipal'
  } 
  scope: serviceBusTopicSubscription
}

// Create fine license key secret and assigne Secrets User role to the fine collection service
module fineLicenseKeySecret 'secrets/fine-license-key.bicep' = {
  name: 'fineCollectionServiceLicenseKeySecret-${uniqueString(resourceGroup().id)}'
  params: {
    fineLicenseKeySecretName: fineLicenseKeySecretName
    keyVaultName: keyVaultName
    fineLicenseKeySecretValue: fineLicenseKeySecretValue
    fineCollectionServicePrincipalId: fineCollectionService.identity.principalId
  }
  scope: resourceGroup(keyVaultSubscriptionId, keyVaultResourceGroupName)
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the fine collection service.')
output fineCollectionServiceContainerAppName string = fineCollectionService.name
