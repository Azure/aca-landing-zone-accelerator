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

@description('The name of the user managed identity used to access ACR and the keyvault.')
param userManagedIdentityName string

// Supporting services
@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet for supporting services of the spoke')
param servicesSubnetName string = 'servicespe'

@description('The name of the service bus namespace.')
param serviceBusName string = 'eslz-sb-${uniqueString(resourceGroup().id)}'
@description('The name of the service bus topic.')
param serviceBusTopicName string
@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string ='eslz-cosmosdb-${uniqueString(resourceGroup().id)}'
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

// Dapr components
@description('The name of Dapr component for the secret store building block.')
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
@description('The tag of the images.')
param imagesTag string = 'latest'
@description('The name of the image for the vehicle registration service.')
param vehicleRegistrationServiceImageName string = 'vehicle-registration-service'
@description('The name of the image for the fine collection service.')
param fineCollectionServiceImageName string = 'fine-collection-service'
@description('The name of the image for the traffic control service.')
param trafficControlServiceImageName string = 'traffic-control-service'
@description('The name of the image for the simulation.')
param simulationImageName string = 'simulation'

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
    servicesSubnetName: servicesSubnetName
    userManagedIdentityName: userManagedIdentityName
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBusTopicAuthorizationRuleName
  }
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: cosmosDbName
  params: {
    cosmosDbName: cosmosDbName
    location: location
    spokeVNetName: spokeVNetName
    servicesSubnetName: servicesSubnetName
    userManagedIdentityName: userManagedIdentityName
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
    userManagedIdentityName: userManagedIdentityName
    
    serviceBusName: serviceBus.outputs.serviceBusName

    cosmosDbName: cosmosDb.outputs.cosmosDbName
    cosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDb.outputs.cosmosDbCollectionName
    
    fineCollectionServiceName: fineCollectionServiceName
    trafficControlServiceName: trafficControlServiceName

    fineLicenseKeySecretName: fineLicenseKeySecretName
    fineLicenseKeySecretValue: fineLicenseKeySecretValue
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
    userManagedIdentityName: userManagedIdentityName

    serviceBusName: serviceBus.outputs.serviceBusName
    serviceBusTopicName: serviceBus.outputs.serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBus.outputs.serviceBusTopicAuthorizationRuleName

    acrName: acrName
    imagesTag: imagesTag
    vehicleRegistrationServiceImageName: vehicleRegistrationServiceImageName
    fineCollectionServiceImageName: fineCollectionServiceImageName
    trafficControlServiceImageName: trafficControlServiceImageName
    simulationImageName: simulationImageName
  }
  dependsOn: [
    daprComponents
  ]
}
