param location string = resourceGroup().location
param containerAppsEnvironmentName string
param acaIdentityName string

@description('The name of the Azure Container Registry.')
param acrName string
@description('The tag of the images.')
param tag string = 'latest'
@description('The name of the image for the vehicle registration service.')
param vehicleRegistrationServiceImageName string = 'vehicle-registration-service'
@description('The name of the image for the fine collection service.')
param fineCollectionServiceImageName string = 'fine-collection-service'
@description('The name of the image for the traffic control service.')
param trafficControlServiceImageName string = 'traffic-control-service'
@description('The name of the image for the simulation.')
param simulationImageName string = 'simulation'

@description('The name of the service for the vehicle registration service.')
param vehicleRegistrationServiceName string = 'vehicle-registration-service'
@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string = 'fine-collection-service'
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string = 'traffic-control-service'
@description('The name of the service for the simulation.')
param simulationName string = 'simulation'

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: acaIdentityName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
} 

resource vehicleRegistrationService 'Microsoft.App/containerApps@2022-03-01' = {
  name: vehicleRegistrationServiceName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${acaIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
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
          identity: acaIdentity.id
        }
      ]
      secrets: []
    }
    template: {
      containers: [
        {
          name: vehicleRegistrationServiceName
          image: '${acrName}.azurecr.io/${vehicleRegistrationServiceImageName}:${tag}'
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

resource fineCollectionService 'Microsoft.App/containerApps@2022-03-01' = {
  name: fineCollectionServiceName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${acaIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      dapr: {
        enabled: true
        appId: fineCollectionServiceName
        appProtocol: 'http'
        appPort: 6001
      }
      secrets: [
      ]
      registries: [
        {
          server: '${acrName}.azurecr.io'
          identity: acaIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: fineCollectionServiceName
          image: '${acrName}.azurecr.io/${fineCollectionServiceImageName}:${tag}'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'VEHICLE_REGISTRATION_SERVICE'
              value: vehicleRegistrationServiceName
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
  dependsOn: [
    vehicleRegistrationService
  ]
}

resource trafficControlService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: trafficControlServiceName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${acaIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
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
          identity: acaIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: trafficControlServiceName
          image: '${acrName}.azurecr.io/${trafficControlServiceImageName}:${tag}'
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
  dependsOn: [
    fineCollectionService
  ]
}

resource simulationService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: simulationName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${acaIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
      ]
      registries: [
        {
          server: '${acrName}.azurecr.io'
          identity: acaIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: simulationName
          image: '${acrName}.azurecr.io/${simulationImageName}:${tag}'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'TRAFFIC_CONTROL_SERVICE_BASE_URL'
              value: 'https://${trafficControlService.properties.configuration.ingress.fqdn}'
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
