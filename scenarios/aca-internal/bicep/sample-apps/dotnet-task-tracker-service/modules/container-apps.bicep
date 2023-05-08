targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

// Services
@description('The name of the service for the backend api service. The name is use as Dapr App ID.')
param backendApiServiceName string

@description('The name of the service for the backend processor service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param backendProcessorServiceName string

@description('The name of the service for the frontend web app service. The name is use as Dapr App ID.')
param frontendWebAppServiceName string

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
@description('The resource ID of the key vault.')
param keyVaultId string

@description('The name of the secret containing the SendGrid API key value for the Backend Background Processor Service.')
param sendGridKeySecretName string

@description('The SendGrid API key for for Backend Background Processor Service.')
@secure()
param sendGridKeySecretValue string

@description('The name of the secret containing the External Azure Storage Access key for the Backend Background Processor Service.')
param externalStorageKeySecretName string

// External Storage
@description('The name of the external Azure Storage Account.')
param externalStorageAccountName string

// Container Registry & Images
@description('The name of the container registry.')
param containerRegistryName string

@description('The image for the backend api service.')
param backendApiServiceImage string

@description('The image for the backend processor service.')
param backendProcessorServiceImage string

@description('The image for the frontend web app service.')
param frontendWebAppServiceImage string

@description('The name of the application insights.')
param applicationInsightsName string

// App Ports
@description('The target and dapr port for the frontend web app service.')
param frontendWebAppPortNumber int

@description('The target and dapr port for the backend api service.')
param backendApiPortNumber int

@description('The dapr port for the backend processor service.')
param backendProcessorPortNumber int

// ------------------
// VARIABLES
// ------------------

var containerRegistryPullRoleGuid='7f951dda-4ed3-4680-a7ca-43fe172d538d'

// ------------------
// RESOURCES
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

//Reference to AppInsights resource
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: containerRegistryName
}

resource containerRegistryUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'aca-user-identity-${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
}

resource containerRegistryPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(containerRegistryName)) {
  name: guid(subscription().id, containerRegistry.id, containerRegistryUserAssignedIdentity.id) 
  scope: containerRegistry
  properties: {
    principalId: containerRegistryUserAssignedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', containerRegistryPullRoleGuid)
    principalType: 'ServicePrincipal'
  }
}

module frontendWebAppService 'container-apps/webapp-frontend-service.bicep' = {
  name: 'frontendWebAppService-${uniqueString(resourceGroup().id)}'
  params: {
    frontendWebAppServiceName: frontendWebAppServiceName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    containerRegistryName: containerRegistryName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentity.id
    frontendWebAppServiceImage: frontendWebAppServiceImage
    appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
    frontendWebAppPortNumber: frontendWebAppPortNumber
    
  }
}

module backendApiService 'container-apps/webapi-backend-service.bicep' = {
  name: 'backendApiService-${uniqueString(resourceGroup().id)}'
  params: {
    backendApiServiceName: backendApiServiceName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    serviceBusName: serviceBusName
    serviceBusTopicName: serviceBusTopicName
    containerRegistryName: containerRegistryName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentity.id
    backendApiServiceImage: backendApiServiceImage
    cosmosDbName: cosmosDbName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDbCollectionName
    appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
    backendApiPortNumber: backendApiPortNumber
  }
}

module backendProcessorService 'container-apps/processor-backend-service.bicep' = {
  name: 'backendProcessorService-${uniqueString(resourceGroup().id)}'
  params: {
    backendProcessorServiceName: backendProcessorServiceName
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.id
    keyVaultId: keyVaultId
    serviceBusName: serviceBusName
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBusTopicAuthorizationRuleName
    containerRegistryName: containerRegistryName
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentity.id
    sendGridKeySecretName: sendGridKeySecretName
    sendGridKeySecretValue: sendGridKeySecretValue
    externalStorageAccountName: externalStorageAccountName
    externalStorageKeySecretName:externalStorageKeySecretName
    backendProcessorServiceImage: backendProcessorServiceImage
    appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
    backendProcessorPortNumber: backendProcessorPortNumber
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the backend processor service.')
output backendProcessorServiceContainerAppName string = backendProcessorService.outputs.backendProcessorServiceContainerAppName

@description('The name of the container app for the backend api service.')
output backendApiServiceContainerAppName string = backendApiService.outputs.backendApiServiceContainerAppName

@description('The name of the container app for the front end web app service.')
output frontendWebAppServiceContainerAppName string = frontendWebAppService.outputs.frontendWebAppServiceContainerAppName

@description('The FQDN of the front end web app.')
output frontendWebAppServiceFQDN string = frontendWebAppService.outputs.frontendWebAppServiceFQDN

@description('The FQDN of the backend web app')
output backendApiServiceFQDN string  = backendApiService.outputs.backendApiServiceFQDN
