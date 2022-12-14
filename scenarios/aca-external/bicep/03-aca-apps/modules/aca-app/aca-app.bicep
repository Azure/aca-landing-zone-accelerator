param name string
param location string = resourceGroup().location

param containerAppEnvironmentId string

param registryServer string
param registryIdentityId string

param useExternalIngress bool = true
param containerPort int = 80

param containerName string
param containerImage string

param resourceCpu string
param resourceMemory string

param envVars array = []

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${registryIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      registries: [
        {
          server: registryServer
          identity: registryIdentityId
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          name: containerName
          image: containerImage
          resources: {
              cpu: json(resourceCpu)
              memory: resourceMemory
          }
          env: envVars
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
}
