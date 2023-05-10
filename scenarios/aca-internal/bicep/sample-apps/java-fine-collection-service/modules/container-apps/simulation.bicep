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

@description('The FQDN of the traffic control service.')
param trafficControlServiceFqdn string

@description('The name of the the simulation.')
param simulationName string

// Container Registry & Image
@description('The name of the container registry.')
param containerRegistryName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The image for the simulation.')
param simulationImage string

// ------------------
// VARIABLES
// ------------------

var containerAppName = 'ca-${simulationName}'

// ------------------
// RESOURCES
// ------------------

resource simulationService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${containerRegistryUserAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
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
          name: simulationName
          image: simulationImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'TRAFFIC_CONTROL_SERVICE_BASE_URL'
              value: 'https://${trafficControlServiceFqdn}'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the simulation.')
output simulationContainerAppName string = simulationService.name
