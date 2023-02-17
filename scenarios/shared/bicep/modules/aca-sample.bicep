param containerAppName string
param location string 
param acrName string
param enableIngress bool 
param managedEnvironmentId string

@description('The User Managed Identity ID of the resource')
param userAssignedIdentityId string


resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        allowInsecure: true
        external: true
        targetPort: 80
        transport: 'auto'
      }
      registries: [
        {
          server: '${acrName}.azurecr.io'
          identity: userAssignedIdentityId
        }
      ]
      secrets: []
    }
    environmentId: managedEnvironmentId
    template: {
      containers: [
        {
          name: 'simple-hello'
          image: '${acrName}.azurecr.io/acahello:latest'
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


output fqdn string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : 'Ingress not enabled'
