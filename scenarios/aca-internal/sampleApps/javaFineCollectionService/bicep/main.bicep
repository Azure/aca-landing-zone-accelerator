@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the service for the vehicle registration service.')
param vehicleRegistrationServiceName string
@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string
@description('The name of the simulation.')
param simulationName string

param containerRegistryUserAssignedIdentityId string
param keyVaultId string

// Supporting services
@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The name of the service bus namespace.')
param serviceBusName string = 'eslz-sb-${uniqueString(resourceGroup().id)}'
@description('The name of the service bus topic.')
param serviceBusTopicName string
@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string ='eslz-cosno-${uniqueString(resourceGroup().id)}'
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

// Dapr components
@description('The name of Dapr component for the secret store building block.')
// We disable lint of this line as it is not a secret but the name of the Dapr component
#disable-next-line secure-secrets-in-params
param secretStoreComponentName string
@description('The name of Dapr component for the pub/sub building block.')
param pubSubComponentName string = 'pubsub'
@description('The name of Dapr component for the state store building block.')
param stateStoreComponentName string

@description('The name of the key vault resource.')
param keyVaultName string

@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string = 'license-key'
@secure()
@description('The license key for Fine Collection Service.')
param fineLicenseKeySecretValue string

// Container apps
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

@description('The name of the deployment of the Dapr components.')
var daprComponentsDeploymentName = 'dapr-components-deployment'
@description('The name of the deployment of container apps.')
var containerAppsDeploymentName = 'container-apps-deployment'

module serviceBus 'modules/service-bus.bicep' = {
  name: serviceBusName
  params: {
    serviceBusName: serviceBusName
    location: location
    spokeVNetName: spokeVNetName
    spokePrivateEndpointsSubnetName: spokePrivateEndpointsSubnetName
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBusTopicAuthorizationRuleName
    fineCollectionServiceName: fineCollectionServiceName
  }
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: cosmosDbName
  params: {
    cosmosDbName: cosmosDbName
    location: location
    spokeVNetName: spokeVNetName
    spokePrivateEndpointsSubnetName: spokePrivateEndpointsSubnetName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDbCollectionName
  }
}

module daprComponents 'modules/dapr-components.bicep' = {
  name: daprComponentsDeploymentName
  params: {
    secretStoreComponentName: secretStoreComponentName
    pubSubComponentName: pubSubComponentName
    stateStoreComponentName: stateStoreComponentName
    
    containerAppsEnvironmentName: containerAppsEnvironmentName
    
    keyVaultName: keyVaultName
    
    serviceBusName: serviceBus.outputs.serviceBusName

    cosmosDbName: cosmosDb.outputs.cosmosDbName
    cosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDb.outputs.cosmosDbCollectionName
    
    fineCollectionServiceName: fineCollectionServiceName
    trafficControlServiceName: trafficControlServiceName
  }
}

module containerApps 'modules/container-apps.bicep' = {
  name:containerAppsDeploymentName
  params: {
    vehicleRegistrationServiceName: vehicleRegistrationServiceName
    fineCollectionServiceName: fineCollectionServiceName
    trafficControlServiceName: trafficControlServiceName
    simulationName: simulationName
    
    location: location
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentityId
    
    keyVaultId: keyVaultId
    fineLicenseKeySecretName: fineLicenseKeySecretName
    fineLicenseKeySecretValue: fineLicenseKeySecretValue

    serviceBusName: serviceBus.outputs.serviceBusName
    serviceBusTopicName: serviceBus.outputs.serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBus.outputs.serviceBusTopicAuthorizationRuleName
    
    cosmosDbName: cosmosDb.outputs.cosmosDbName
    cosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    
    acrName: acrName
    vehicleRegistrationServiceImage: vehicleRegistrationServiceImage
    fineCollectionServiceImage: fineCollectionServiceImage
    trafficControlServiceImage: trafficControlServiceImage
    simulationImage: simulationImage
  }
  dependsOn: [
    daprComponents
  ]
}
