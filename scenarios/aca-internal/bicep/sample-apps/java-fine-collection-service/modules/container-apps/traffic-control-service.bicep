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

@description('The name of the service for the traffic control service. The name is use as Dapr App ID.')
param trafficControlServiceName string

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

@description('The image for the traffic control service.')
param trafficControlServiceImage string

// ------------------
// VARIABLES
// ------------------

var containerAppName = 'ca-${trafficControlServiceName}'

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

resource trafficControlService 'Microsoft.App/containerApps@2022-06-01-preview' = {
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
      ingress: {
        external: true
        targetPort: 6000
        allowInsecure: false
      }
      dapr: {
        enabled: true
        appId: trafficControlServiceName
        appProtocol: 'http'
        appPort: 6000
        logLevel: 'info'
      }
      secrets: [
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
          name: trafficControlServiceName
          image: trafficControlServiceImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// Enable send to servicebus using app managed identity.
resource trafficControlServiceSbRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, trafficControlService.name, '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
  properties: {
    principalId: trafficControlService.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39') //Azure Service Bus Data Sender
    principalType: 'ServicePrincipal'
  }
  
  scope: serviceBusTopic
}

// Assign cosmosdb account read/write access to aca user assigned identity
// To know more: https://learn.microsoft.com/azure/cosmos-db/how-to-setup-rbac
resource cosmosDbCollectionDataContributorRoleAssignment  'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  name: guid(subscription().id, trafficControlService.name, '00000000-0000-0000-0000-000000000002')
  parent: cosmosDbAccount
  properties: {
    principalId: trafficControlService.identity.principalId
    roleDefinitionId:  resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccount.name, '00000000-0000-0000-0000-000000000002') //DocumentDB Data Contributor
    scope: '${cosmosDbAccount.id}/dbs/${cosmosDbDatabase.name}/colls/${cosmosDbDatabaseCollection.name}'
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the traffic control service.')
output trafficControlServiceContainerAppName string = trafficControlService.name

@description('The FQDN of the traffic control service.')
output trafficControlServiceFqdn string = trafficControlService.properties.configuration.ingress.fqdn
