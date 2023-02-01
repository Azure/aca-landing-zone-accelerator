//targetScope = 'subscription'
param location string = resourceGroup().location
param containerAppName string
param useExternalIngress bool
param containerPort int
param acaIdentityName string 
param envVars array = []
param containerEnvname string
param acrName string //User to provide each time
// param containerImage string = '${acrName}.azurecr.io/samples/nginx:latest' //User to provide each time
param containerImage string //User to provide each time


resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
    name: acaIdentityName
  }

  resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
    name: containerEnvname
  }

  resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
    name: containerAppName
    location: location    
    identity: {
        type: 'SystemAssigned,UserAssigned'
        userAssignedIdentities: {
            '${acaIdentity.id}': {}
        }
    }
    properties: {
        managedEnvironmentId: containerAppEnvironment.id
        configuration: {
            
            
            registries: [
                {
                    server: '${acrName}.azurecr.io'
                    //username: acrName
                    //passwordSecretRef: 'acrtokenpwd'
                    identity: acaIdentity.id
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
                    image: containerImage
                    name: 'acasrtest'
                   
                }
            ]
            scale: {
                minReplicas: 1
            }
        }
    }
}
