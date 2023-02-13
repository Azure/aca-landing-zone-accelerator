@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location
@description('The name of the container apps environment.')
param containerAppsEnvironmentName string
@description('The name of the user managed identity used to access ACR.')
param userManagedIdentityName string

@description('The name of the service for the vehicle registration service.')
param vehicleRegistrationServiceName string
@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string
@description('The name of the the simulation.')
param simulationName string

@description('The name of the service bus namespace.')
param serviceBusName string
@description('The name of the service bus topic.')
param serviceBusTopicName string
@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

@description('The name of the Azure Container Registry.')
param acrName string
@description('The image for the vehicle registration service.')
param vehicleRegistrationServiceImage string
@description('The image for the fine collection service.')
param fineCollectionServiceImage string
@description('The image for the traffic control service.')
param trafficControlServiceImage string
@description('The image for the simulation.')
param simulationImage string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userManagedIdentityName
}

resource serviceBusTopicAuthorizationRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' existing = {
  name: '${serviceBusName}/${serviceBusTopicName}/${serviceBusTopicAuthorizationRuleName}'
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
        {
          name: 'service-bus-connection-string'
          value: serviceBusTopicAuthorizationRule.listKeys().primaryConnectionString
        }
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
          image: fineCollectionServiceImage
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
          image: simulationImage
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
