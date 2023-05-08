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

@description('The name of the service for the backend api service. The name is use as Dapr App ID.')
param backendApiServiceName string

// Service Bus
@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the service bus topic.')
param serviceBusTopicName string

// Cosmos DB
@description('The name of the provisioned Cosmos DB resource.')
param cosmosDbName string 

@description('The name of the provisioned Cosmos DB\'s database.')
param cosmosDbDatabaseName string

@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The image for the backend api service.')
param backendApiServiceImage string

@secure()
@description('The Application Insights Instrumentation.')
param appInsightsInstrumentationKey string

@description('The target and dapr port for the backend api service.')
param backendApiPortNumber int

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

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' existing = {
  name: cosmosDbDatabaseName
  parent: cosmosDbAccount
}

resource cosmosDbDatabaseCollection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-05-15' existing = {
  name: cosmosDbCollectionName
  parent: cosmosDbDatabase
}

resource backendApiService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: backendApiServiceName
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
      ingress: {
        external: false
        targetPort: backendApiPortNumber
      }
      dapr: {
        enabled: true
        appId: backendApiServiceName
        appProtocol: 'http'
        appPort: backendApiPortNumber
        logLevel: 'info'
        enableApiLogging: true
      }
      registries: !empty(containerRegistryName) ? [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: containerRegistryUserAssignedIdentityId
        }
      ] : []
      secrets: [
        {
          name: 'appinsights-key'
          value: appInsightsInstrumentationKey
        }
      ]
    }
    template: {
      containers: [
        {
          name: backendApiServiceName
          image: backendApiServiceImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
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
      }
    }
  }
}

// Assign cosmosdb account read/write access to aca system assigned identity
// To know more: https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac
resource backendApiService_cosmosdb_role_assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  name: guid(subscription().id, backendApiService.name, '00000000-0000-0000-0000-000000000002')
  parent: cosmosDbAccount
  properties: {
    principalId: backendApiService.identity.principalId
    roleDefinitionId:  resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccount.name, '00000000-0000-0000-0000-000000000002')//DocumentDB Data Contributor
    scope: '${cosmosDbAccount.id}/dbs/${cosmosDbDatabase.name}/colls/${cosmosDbDatabaseCollection.name}'
  }
}

// Enable publish message to Service Bus using app managed identity.
resource backendApiService_sb_role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, backendApiService.name, '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
  properties: {
    principalId: backendApiService.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')//Azure Service Bus Data Sender
    principalType: 'ServicePrincipal'
  }
  scope: serviceBusTopic
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the backend api service.')
output backendApiServiceContainerAppName string = backendApiService.name

@description('The FQDN of the backend api service.')
output backendApiServiceFQDN string = backendApiService.properties.configuration.ingress.fqdn
