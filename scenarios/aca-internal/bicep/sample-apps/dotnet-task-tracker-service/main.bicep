targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param workloadName string

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

// Servivces
@description('The name of the service for the backend processor service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param backendProcessorServiceName string

@description('The name of the service for the backend api service. The name is use as Dapr App ID.')
param backendApiServiceName string

@description('The name of the service for the frontend web app service. The name is use as Dapr App ID.')
param frontendWebAppServiceName string

// App Ports
@description('The target and dapr port for the frontend web app service.')
param frontendWebAppPortNumber int = 80

@description('The target and dapr port for the backend api service.')
param backendApiPortNumber int = 80

@description('The dapr port for the backend processor service.')
param backendProcessorPortNumber int = 80

// Spoke Private Endpoints Subnet
@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string

@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

@description('The name of the external Queue in Azure Storage.')
param externalTasksQueueName string

//SendGrid
@description('The name of the secret containing the SendGrid API key value for the backend processor service.')
param sendGridKeySecretName string = 'sendgrid-api-key'

@description('The name of the SendGrid Email From.')
param sendGridEmailFrom string

@description('The name of the SendGrid Email From Name.')
param sendGridEmailFromName string

@description('The SendGrid API key for the backend processor service. If not provided, SendGrid integration will be disabled.')
@secure()
param sendGridKeySecretValue string

// Key Vault
@description('The resource ID of the key vault to store the license key for the fine collection service.')
param keyVaultId string

//Cron Shedule Jon
@description('The cron settings for scheduled job.')
param scheduledJobCron string

@description('The name of the external blob container in Azure Storage.')
param externalTasksContainerBlobName string

@description('The name of the secret containing the External Azure Storage Access key for the backend processor service.')
param externalStorageKeySecretName string 

// Container Registry & Images
@description('The name of the container registry.')
param containerRegistryName string

@description('The image for the backend processor service.')
param backendProcessorServiceImage string

@description('The image for the backend api service.')
param backendApiServiceImage string

@description('The image for the frontend web app service.')
param frontendWebAppServiceImage string

// Application Gateway
@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param applicationGatewayFQDN string

@description('The subnet name to use for Application Gateway.')
param spokeApplicationGatewaySubnetName string

@description('Enable or disable Application Gateway Certificate (PFX).')
param enableApplicationGatewayCertificate bool

@description('The name of the certificate key to use for Application Gateway certificate.')
param applicationGatewayCertificateKeyName string

@description('Application Insights Name.')
param applicationInsightsName string

var appInsightName = empty(applicationInsightsName) ? naming.outputs.resourcesNames.applicationInsights : applicationInsightsName

// ------------------
// VARIABLES
// ------------------

var keyVaultIdTokens = split(keyVaultId, '/')
var keyVaultName = keyVaultIdTokens[8]

var secretStoreComponentName = 'secretstoreakv'

var appGatewayBackendHealthProbePath = '/'


// ------------------
// RESOURCES
// ------------------

module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('dotnettasktracker-shared-${uniqueString(resourceGroup().id)}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}

module serviceBus 'modules/service-bus.bicep' = {
  name: 'serviceBus-${uniqueString(resourceGroup().id)}'
  params: {
    serviceBusName: naming.outputs.resourcesNames.serviceBus
    location: location
    tags: tags
    spokeVNetName: spokeVNetName
    spokePrivateEndpointsSubnetName: spokePrivateEndpointsSubnetName
    serviceBusTopicName: serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBusTopicAuthorizationRuleName
    backendProcessorServiceName: backendProcessorServiceName
    serviceBusPrivateEndpointName: naming.outputs.resourcesNames.serviceBusPep
    hubVNetId: hubVNetId
  }
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: 'cosmosDb-${uniqueString(resourceGroup().id)}'
  params: {
    cosmosDbName: naming.outputs.resourcesNames.cosmosDbNoSql
    location: location
    tags: tags
    spokeVNetName: spokeVNetName
    spokePrivateEndpointsSubnetName: spokePrivateEndpointsSubnetName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDbCollectionName
    cosmosDbPrivateEndpointName: naming.outputs.resourcesNames.cosmosDbNoSqlPep
    hubVNetId: hubVNetId
  }
}

// TODO add private endpoint for storage account
module externalStorageAccount 'modules/storage-account.bicep' = {
  name: 'storageAccount-${uniqueString(resourceGroup().id)}'
  params: {
    storageAccountName: naming.outputs.resourcesNames.storageAccount
    externalTasksQueueName: externalTasksQueueName
    location: location
    tags: tags
    blobPrivateEndpointName: 'blob-${naming.outputs.resourcesNames.storageAccountPep}'
    queuePrivateEndpointName: 'queue-${naming.outputs.resourcesNames.storageAccountPep}'
    hubVNetId: hubVNetId
    spokePrivateEndpointsSubnetName: spokePrivateEndpointsSubnetName
    spokeVNetName: spokeVNetName
  }
}

module daprComponents 'modules/dapr-components.bicep' = {
  name: 'daprComponents-${uniqueString(resourceGroup().id)}'
  params: {
    secretStoreComponentName: secretStoreComponentName 
    containerAppsEnvironmentName: containerAppsEnvironmentName    
    keyVaultName: keyVaultName    
    serviceBusName: serviceBus.outputs.serviceBusName
    cosmosDbName: cosmosDb.outputs.cosmosDbName
    cosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDb.outputs.cosmosDbCollectionName    
    backendApiServiceName: backendApiServiceName
    backendProcessorServiceName: backendProcessorServiceName
    storageAccountName: naming.outputs.resourcesNames.storageAccount
    sendGridKeySecretName: sendGridKeySecretName
    sendGridEmailFrom: sendGridEmailFrom
    sendGridEmailFromName: sendGridEmailFromName
    scheduledJobCron: scheduledJobCron
    externalTasksQueueName: externalTasksQueueName
    externalTasksContainerBlobName: externalTasksContainerBlobName
    externalStorageKeySecretName: externalStorageKeySecretName
  }
}

module containerApps 'modules/container-apps.bicep' = {
  name: 'containerApps-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    tags: tags
    backendProcessorServiceName: backendProcessorServiceName
    backendApiServiceName: backendApiServiceName
    frontendWebAppServiceName: frontendWebAppServiceName    
    containerAppsEnvironmentName: containerAppsEnvironmentName
    keyVaultId: keyVaultId
    serviceBusName: serviceBus.outputs.serviceBusName
    serviceBusTopicName: serviceBus.outputs.serviceBusTopicName
    serviceBusTopicAuthorizationRuleName: serviceBus.outputs.serviceBusTopicAuthorizationRuleName    
    cosmosDbName: cosmosDb.outputs.cosmosDbName
    cosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    cosmosDbCollectionName: cosmosDb.outputs.cosmosDbCollectionName    
    containerRegistryName: containerRegistryName
    backendProcessorServiceImage: backendProcessorServiceImage
    backendApiServiceImage: backendApiServiceImage
    frontendWebAppServiceImage: frontendWebAppServiceImage
    sendGridKeySecretName: sendGridKeySecretName
    sendGridKeySecretValue: sendGridKeySecretValue
    applicationInsightsName: appInsightName
    externalStorageAccountName: externalStorageAccount.outputs.storageAccountName
    externalStorageKeySecretName: externalStorageKeySecretName
    frontendWebAppPortNumber: frontendWebAppPortNumber
    backendApiPortNumber: backendApiPortNumber
    backendProcessorPortNumber: backendProcessorPortNumber
  }
  dependsOn: [
    daprComponents
  ]
}

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource spokeApplicationGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: spokeApplicationGatewaySubnetName
  parent: spokeVNet
}

module applicationGateway '../../modules/06-application-gateway/deploy.app-gateway.bicep' = {
  name: 'applicationGateway-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    tags: tags
    environment: environment
    workloadName: workloadName
    applicationGatewayFQDN: applicationGatewayFQDN
    applicationGatewaySubnetId: spokeApplicationGatewaySubnet.id
    applicationGatewayPrimaryBackendEndFQDN: containerApps.outputs.frontendWebAppServiceFQDN
    appGatewayBackendHealthProbePath: appGatewayBackendHealthProbePath
    enableApplicationGatewayCertificate: enableApplicationGatewayCertificate
    applicationGatewayCertificateKeyName: applicationGatewayCertificateKeyName
    keyVaultId: keyVaultId
  }
}

// ------------------
// OUTPUTS
// ------------------
@description('The FQDN of the application gateway.')
output applicationGatewayFQDN string = applicationGateway.outputs.applicationGatewayFqdn

@description('The public IP address of the application gateway.')
output applicationGatewayPublicIp string = applicationGateway.outputs.applicationGatewayPublicIp
