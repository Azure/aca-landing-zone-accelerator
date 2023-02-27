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

@description('The name of the service for the vehicle registration service.')
param vehicleRegistrationServiceName string

// Container Registry & Image
@description('The name of the Azure Container Registry.')
param acrName string
@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string
@description('The image for the vehicle registration service.')
param vehicleRegistrationServiceImage string

// ------------------
//    VARIABLES
// ------------------

var containerAppName = 'ca-${vehicleRegistrationServiceName}'

// ------------------
// DEPLOYMENT TASKS
// ------------------

resource vehicleRegistrationService 'Microsoft.App/containerApps@2022-03-01' = {
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
      dapr: {
        enabled: true
        appId: vehicleRegistrationServiceName
        appProtocol: 'http'
        appPort: 6002
      }
      registries: [
        {
          server: '${acrName}.azurecr.io'
          identity: containerRegistryUserAssignedIdentityId
        }
      ]
      secrets: []
    }
    template: {
      containers: [
        {
          name: vehicleRegistrationServiceName
          image: vehicleRegistrationServiceImage
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

// ------------------
// OUTPUTS
// ------------------

@description('Dapr App Id of the vehicle registration service.')
output vehicleRegistrationServiceDaprAppId string = vehicleRegistrationService.properties.configuration.dapr.appId
