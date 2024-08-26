param managedEnvironments_name string
param eureka_id string
param configserver_id string
param acr_identity_id string
param image_tag string

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: managedEnvironments_name
}

module app_gateway 'containerapp.bicep' = {
  name: 'spring-petclinic-gateway'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'spring-petclinic-gateway'
    eurekaId: eureka_id
    configServerId: configserver_id
    registry: 'crlzaacauhge5deveus.azurecr.io'
    image: 'spring-petclinic-api-gateway:3.0.1-${image_tag}'
    containerRegistryUserAssignedIdentityId: acr_identity_id
    external: true
  }
}

module app_customer_service 'containerapp.bicep' = {
  name: 'customer-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'customer-service'
    eurekaId: eureka_id
    configServerId: configserver_id
    registry: 'crlzaacauhge5deveus.azurecr.io'
    image: 'spring-petclinic-customers-service:3.0.1-${image_tag}'
    containerRegistryUserAssignedIdentityId: acr_identity_id
    external: false
  }
}

module app_vets_service 'containerapp.bicep' = {
  name: 'vets-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'vets-service'
    eurekaId: eureka_id
    configServerId: configserver_id
    registry: 'crlzaacauhge5deveus.azurecr.io'
    image: 'spring-petclinic-vets-service:3.0.1-${image_tag}'
    containerRegistryUserAssignedIdentityId: acr_identity_id
    external: false
  }
}

module app_visits_service 'containerapp.bicep' = {
  name: 'visits-service'
  params: {
    location: environment.location
    managedEnvironmentId: environment.id
    appName: 'visits-service'
    eurekaId: eureka_id
    configServerId: configserver_id
    registry: 'crlzaacauhge5deveus.azurecr.io'
    image: 'spring-petclinic-visits-service:3.0.1-${image_tag}'
    containerRegistryUserAssignedIdentityId: acr_identity_id
    external: false
  }
}

output fqdn string = app_gateway.outputs.appFqdn
