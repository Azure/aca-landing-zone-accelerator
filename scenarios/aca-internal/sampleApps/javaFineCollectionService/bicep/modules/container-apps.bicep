targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

@description('The resource ID of the key vault to store the license key for the fine collection service.')
param keyVaultId string
@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string
@secure()
@description('The license key for Fine Collection Service.')
param fineLicenseKeySecretValue string

@description('The name of the service for the vehicle registration service.')
param vehicleRegistrationServiceName string
@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string
@description('Optional. The name of the the simulation. If it is not set, the simulation will not be deployed.')
param simulationName string = ''

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
@description('Optional. The image for the simulation. If the simulation name is set, this parameter is required.')
param simulationImage string = ''

// ------------------
// DEPLOYMENT TASKS
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

module vehicleRegistrationService 'container-apps/vehicle-registration-service.bicep' = {
  name: 'vehicleRegistrationService-${uniqueString(resourceGroup().id)}'
  params: {
    vehicleRegistrationServiceName: vehicleRegistrationServiceName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    vehicleRegistrationServiceImage: vehicleRegistrationServiceImage
  }
}

module fineCollectionService 'container-apps/fine-collection-service.bicep' = {
  name: 'fineCollectionService-${uniqueString(resourceGroup().id)}'
  params: {
    fineCollectionServiceName: fineCollectionServiceName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    vehicleRegistrationServiceDaprAppId: vehicleRegistrationService.outputs.vehicleRegistrationServiceDaprAppId
    keyVaultId: keyVaultId
    fineLicenseKeySecretName: fineLicenseKeySecretName
    fineLicenseKeySecretValue: fineLicenseKeySecretValue
    serviceBusName: serviceBusName
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBusTopicAuthorizationRuleName
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    fineCollectionServiceImage: fineCollectionServiceImage
  }
}

module trafficControlService 'container-apps/traffic-control-service.bicep' = {
  name: 'trafficControlService-${uniqueString(resourceGroup().id)}'
  params: {
    trafficControlServiceName: trafficControlServiceName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
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

module simulation 'container-apps/simulation.bicep' = if (simulationName != '') {
  name: 'simulation-${uniqueString(resourceGroup().id)}'
  params: {
    simulationName: simulationName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    trafficControlServiceFQDN: trafficControlService.outputs.trafficControlServiceFQDN
    acrName: acrName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    simulationImage: simulationImage
  }
}
