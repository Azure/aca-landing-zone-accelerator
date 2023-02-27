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

@description('The name of the service for the traffic control service.')
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

// Container Registry & Image
@description('The name of the Azure Container Registry.')
param acrName string
@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string
@description('The image for the traffic control service.')
param trafficControlServiceImage string

// ------------------
//    VARIABLES
// ------------------

var containerAppName = 'ca-${trafficControlServiceName}'

// ------------------
// DEPLOYMENT TASKS
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
        external: false
        targetPort: 6000
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
      registries: [
        {
          server: '${acrName}.azurecr.io'
          identity: containerRegistryUserAssignedIdentityId
        }
      ]
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

//enable send to servicebus using app managed identity.
resource trafficControlService_sb_role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, trafficControlService.name, '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
  properties: {
    principalId: trafficControlService.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')//Azure Service Bus Data Sender
    principalType: 'ServicePrincipal'
  }
  
  scope: serviceBusTopic
}

//assign cosmosdb account read/write access to aca user assigned identity
resource trafficControlService_cosmosdb_role_assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  name: guid(subscription().id, trafficControlService.name, '00000000-0000-0000-0000-000000000002')
  parent: cosmosDbAccount
  properties: {
    principalId: trafficControlService.identity.principalId
    roleDefinitionId:  resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccount.name, '00000000-0000-0000-0000-000000000002')//DocumentDB Data Contributor
    scope:cosmosDbAccount.id
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The FQDN of the traffic control service.')
output trafficControlServiceFQDN string = trafficControlService.properties.configuration.ingress.fqdn
