@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location
@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string
param keyVaultUserAssignedIdentityId string

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

@description('The name of the provisioned Cosmos DB resource.')
param cosmosDbName string 
@description('The name of the provisioned Cosmos DB\'s database.')
param cosmosDbDatabaseName string

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

module vehicleRegistrationService 'container-apps/vehicle-registration-service.bicep' = {
  name: 'vehicleRegistrationService'
  params: {
    vehicleRegistrationServiceName: vehicleRegistrationServiceName
    location: location
    // TODO update to id?
    containerAppsEnvironmentName: containerAppsEnvironmentName
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    vehicleRegistrationServiceImage: vehicleRegistrationServiceImage
  }
}

module fineCollectionService 'container-apps/fine-collection-service.bicep' = {
  name: 'fineCollectionService'
  params: {
    fineCollectionServiceName: fineCollectionServiceName
    location: location
    // TODO update to id?
    containerAppsEnvironmentName: containerAppsEnvironmentName
    vehicleRegistrationServiceDaprAppId: vehicleRegistrationService.outputs.vehicleRegistrationServiceDaprAppId
    serviceBusName: serviceBusName
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBusTopicAuthorizationRuleName
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    fineCollectionServiceImage: fineCollectionServiceImage
    keyVaultUserAssignedIdentityId: keyVaultUserAssignedIdentityId
  }
}

module trafficControlService 'container-apps/traffic-control-service.bicep' = {
  name: 'trafficControlService'
  params: {
    trafficControlServiceName: trafficControlServiceName
    location: location
    // TODO update to id?
    containerAppsEnvironmentName: containerAppsEnvironmentName
    serviceBusName: serviceBusName
    serviceBusTopicName: serviceBusTopicName
    cosmosDbName: cosmosDbName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    trafficControlServiceImage: trafficControlServiceImage
  }
  // The traffic control service is deployed after the fine collection service
  dependsOn: [
    fineCollectionService
  ]
}

// TODO add a flag to deploy the simulation
module simulation 'container-apps/simulation.bicep' = {
  name: 'simulation'
  params: {
    simulationName: simulationName
    location: location
    // TODO update to id?
    containerAppsEnvironmentName: containerAppsEnvironmentName
    trafficControlServiceFQDN: trafficControlService.outputs.trafficControlServiceFQDN
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    simulationImage: simulationImage
  }
}
