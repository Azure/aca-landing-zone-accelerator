param managedEnvironmentsName string
param eurekaId string
param configServerId string

param mysqlDBId string
param mysqlUserAssignedIdentityClientId string

param imageTag string
param acrRegistry string
param acrIdentityId string

param apiGatewayImage string = 'spring-petclinic-api-gateway'
param customerServiceImage string = 'spring-petclinic-customers-service'
param vetsServiceImage string = 'spring-petclinic-vets-service'
param visitsServiceImage string = 'spring-petclinic-visits-service'

param targetPort int = 8080

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: managedEnvironmentsName
}

module apiGateway 'containerapp.bicep' = {
  name: 'api-gateway'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'api-gateway'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: '${apiGatewayImage}:${imageTag}'
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: true
    targetPort: targetPort
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
  }
}

module customerService 'containerapp.bicep' = {
  name: 'customer-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'customer-service'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: '${customerServiceImage}:${imageTag}'
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
  }
}

module vetsService 'containerapp.bicep' = {
  name: 'vets-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'vets-service'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: '${vetsServiceImage}:${imageTag}'
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
  }
}

module visitsService 'containerapp.bicep' = {
  name: 'visits-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'visits-service'
    eurekaId: eurekaId
    configServerId: configServerId
    registry: acrRegistry
    image: '${visitsServiceImage}:${imageTag}'
    containerRegistryUserAssignedIdentityId: acrIdentityId
    external: false
    targetPort: targetPort
    mysqlDBId: mysqlDBId
    mysqlUserAssignedIdentityClientId: mysqlUserAssignedIdentityClientId
  }
}

output fqdn string = apiGateway.outputs.appFqdn
output gatewayId string = apiGateway.outputs.appId
output customerServiceId string = customerService.outputs.appId
output vetsServiceId string = vetsService.outputs.appId
output visitsServiceId string = visitsService.outputs.appId
