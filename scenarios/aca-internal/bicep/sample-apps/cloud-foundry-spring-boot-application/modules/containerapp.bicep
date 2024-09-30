param location string
param managedEnvironmentId string
param registry string = 'mcr.microsoft.com'
param image string = 'k8se/quickstart'
param appName string
param eurekaId string
param configServerId string
param external bool = false
param containerRegistryUserAssignedIdentityId string
param mysqlDBId string
param mysqlUserAssignedIdentityClientId string
param targetPort int

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
        targetPort: targetPort
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
          env: [
            {
              name: 'SPRING_PROFILES_ACTIVE'
              value: 'passwordless'
            }
          ]
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

var mysqlToken = !empty(mysqlDBId) ? split(mysqlDBId, '/') : array('')
var mysqlSubscriptionId = mysqlToken[2]
var normalizedAppName = replace(appName, '-', '_')

resource connectDB 'Microsoft.ServiceLinker/linkers@2023-04-01-preview' = {
  name: 'mysql_${normalizedAppName}'
  scope: app
  properties: { 
    scope: appName
    clientType: 'springBoot'
    authInfo: {
      authType: 'userAssignedIdentity'
      clientId: mysqlUserAssignedIdentityClientId
      subscriptionId: mysqlSubscriptionId
      userName: 'aad_mysql_${normalizedAppName}'
    }
    targetService: {
      type: 'AzureResource'
      id: mysqlDBId
    }
  }
}

output appId string = app.id
output appFqdn string = app.properties.configuration.ingress != null ? app.properties.configuration.ingress.fqdn : ''
