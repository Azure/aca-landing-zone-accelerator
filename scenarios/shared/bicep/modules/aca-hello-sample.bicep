@description('Required. Name of your Azure Container sample. ')
param name string

@description('Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

param enableIngress bool = true 
param managedEnvironmentId string

@description('The User Managed Identity ID of the resource')
param userAssignedIdentityId string


resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: name
  location: location
  tags: tags
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
      registries: []
      secrets: []
      // dapr: []
    }
    environmentId: managedEnvironmentId
    template: {
      containers: [
        {
          name: 'simple-hello'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
      volumes: []
    }
  }
}


output fqdn string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : 'Ingress not enabled'
