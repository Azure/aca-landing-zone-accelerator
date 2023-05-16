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

// Services
@description('The name of the service for the vehicle registration service. The name is use as Dapr App ID and for service-to-service invocation by fine collection service.')
param vehicleRegistrationServiceName string

@description('The name of the service for the fine collection service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param fineCollectionServiceName string

@description('The name of the service for the traffic control service. The name is use as Dapr App ID.')
param trafficControlServiceName string

// Service Bus
@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

// Cosmos DB
@description('The name of the provisioned Cosmos DB resource.')
param cosmosDbName string 

@description('The name of the provisioned Cosmos DB\'s database.')
param cosmosDbDatabaseName string

@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

// Key Vault
@description('The resource ID of the key vault to store the license key for the fine collection service.')
param keyVaultId string

@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string = 'license-key'

@secure()
@description('The license key for Fine Collection Service.')
param fineLicenseKeySecretValue string

// Container Registry & Images
@description('The name of the container registry.')
param containerRegistryName string

@description('The image for the vehicle registration service.')
param vehicleRegistrationServiceImage string

@description('The image for the fine collection service.')
param fineCollectionServiceImage string

@description('The image for the traffic control service.')
param trafficControlServiceImage string

// Simulation
@description('If true, the simulation will be deployed in the environment and use the traffic control service FQDN.')
param deploySimulationInAcaEnvironment bool

@description('Optional. The name of the the simulation. If deploySimulationInAcaEnvironment is set to true, this parameter is required.')
param simulationName string = ''

@description('Optional. The image for the simulation. If deploySimulationInAcaEnvironment is set to true, this parameter is required.')
param simulationImage string = ''

// ------------------
// RESOURCES
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
    containerRegistryName: containerRegistryName
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
    containerRegistryName: containerRegistryName
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
    cosmosDbCollectionName: cosmosDbCollectionName
    containerRegistryName: containerRegistryName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    trafficControlServiceImage: trafficControlServiceImage
  }
  // The traffic control service is deployed after the fine collection service
  dependsOn: [
    fineCollectionService
  ]
}

module simulation 'container-apps/simulation.bicep' = if (deploySimulationInAcaEnvironment) {
  name: 'simulation-${uniqueString(resourceGroup().id)}'
  params: {
    simulationName: simulationName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    trafficControlServiceFqdn: trafficControlService.outputs.trafficControlServiceFqdn
    containerRegistryName: containerRegistryName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    simulationImage: simulationImage
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the vehicle registration service.')
output vehicleRegistrationServiceContainerAppName string = vehicleRegistrationService.outputs.vehicleRegistrationServiceContainerAppName

@description('The name of the container app for the fine collection service.')
output fineCollectionServiceContainerAppName string = fineCollectionService.outputs.fineCollectionServiceContainerAppName

@description('The name of the container app for the traffic control service.')
output trafficControlServiceContainerAppName string = trafficControlService.outputs.trafficControlServiceContainerAppName

@description('The name of the container app for the simulation. If deploySimulationInAcaEnvironment is set to false, this output will be empty.')
output simulationContainerAppName string = (deploySimulationInAcaEnvironment) ? simulation.outputs.simulationContainerAppName : ''

@description('The FQDN of the traffic control service.')
output trafficControlServiceFqdn string = trafficControlService.outputs.trafficControlServiceFqdn
