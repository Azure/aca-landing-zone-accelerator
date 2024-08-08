param location string
param managedEnvironmentId string
param registry string = 'mcr.microsoft.com'
param image string = 'k8se/quickstart'
param appName string
param eurekaId string
param configServerId string
param external bool = false
param containerRegistryUserAssignedIdentityId string

resource app 'Microsoft.App/containerApps@2024-02-02-preview' = {
  name: appName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerRegistryUserAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      ingress:{
        external: external
        targetPort: 8080
      }
      registries: containerRegistryUserAssignedIdentityId == null ? null : [
        {
          server: registry
          identity: containerRegistryUserAssignedIdentityId
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${registry}/${image}'
          imageType: 'ContainerImage'
          name: appName
          resources: {
            cpu: 1
            memory: '2Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
      }
      serviceBinds: [
        {
          serviceId: eurekaId
          name: 'eureka'
        }
        {
          serviceId: configServerId
          name: 'configserver'
        }
      ]
    }
  }
}

output appId string = app.id
output appFqdn string = app.properties.configuration.ingress != null ? app.properties.configuration.ingress.fqdn : ''
