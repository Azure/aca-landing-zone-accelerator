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
@description('The name of the service for the vehicle registration service. The name is use as Dapr App ID and for service-to-service invocation by fine collection service.')
param vehicleRegistrationServiceName string

@description('The name of the service for the fine collection service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param fineCollectionServiceName string

@description('The name of the service for the traffic control service. The name is use as Dapr App ID.')
param trafficControlServiceName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

// Spoke Private Endpoints Subnet
@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

// Service Bus
@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

// Cosmos DB
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

// Key Vault
@description('The resource ID of the key vault to store the license key for the fine collection service.')
param keyVaultId string

@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string = 'license-key'

@description('The license key for Fine Collection Service.')
@secure()
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

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
param containerRegistryUserAssignedIdentityId string

// Simulation
@description('If true, the simulation will be deployed in the environment and use the traffic control service FQDN.')
param deploySimulationInAcaEnvironment bool

@description('Optional. The name of the the simulation. If deploySimulationInAcaEnvironment is set to true, this parameter is required.')
param simulationName string = ''

@description('Optional. The image for the simulation. If deploySimulationInAcaEnvironment is set to true, this parameter is required.')
param simulationImage string = ''

// Application Gateway
@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param applicationGatewayFqdn string

@description('The subnet name to use for Application Gateway.')
param spokeApplicationGatewaySubnetName string

@description('Enable or disable Application Gateway Certificate (PFX).')
param enableApplicationGatewayCertificate bool

@description('The name of the certificate key to use for Application Gateway certificate.')
param applicationGatewayCertificateKeyName string


// ------------------
// VARIABLES
// ------------------

var keyVaultIdTokens = split(keyVaultId, '/')
var keyVaultName = keyVaultIdTokens[8]

var appGatewayBackendHealthProbePath = '/healthz'

// ------------------
// RESOURCES
// ------------------

module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('javaFineCollection-sharedNamingDeployment-${uniqueString(resourceGroup().id)}', 64)
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
    fineCollectionServiceName: fineCollectionServiceName
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

module daprComponents 'modules/dapr-components.bicep' = {
  name: 'daprComponents-${uniqueString(resourceGroup().id)}'
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
  name: 'containerApps-${uniqueString(resourceGroup().id)}'
  params: {
    vehicleRegistrationServiceName: vehicleRegistrationServiceName
    fineCollectionServiceName: fineCollectionServiceName
    trafficControlServiceName: trafficControlServiceName    
    location: location
    tags: tags
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
    cosmosDbCollectionName: cosmosDb.outputs.cosmosDbCollectionName    
    containerRegistryName: containerRegistryName
    vehicleRegistrationServiceImage: vehicleRegistrationServiceImage
    fineCollectionServiceImage: fineCollectionServiceImage
    trafficControlServiceImage: trafficControlServiceImage
    deploySimulationInAcaEnvironment: deploySimulationInAcaEnvironment
    simulationName: simulationName
    simulationImage: simulationImage
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
    applicationGatewayFqdn: applicationGatewayFqdn
    applicationGatewaySubnetId: spokeApplicationGatewaySubnet.id
    applicationGatewayPrimaryBackendEndFqdn: containerApps.outputs.trafficControlServiceFqdn
    appGatewayBackendHealthProbePath: appGatewayBackendHealthProbePath
    enableApplicationGatewayCertificate: enableApplicationGatewayCertificate
    applicationGatewayCertificateKeyName: applicationGatewayCertificateKeyName
    keyVaultId: keyVaultId
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the container app for the vehicle registration service.')
output vehicleRegistrationServiceContainerAppName string = containerApps.outputs.vehicleRegistrationServiceContainerAppName

@description('The name of the container app for the fine collection service.')
output fineCollectionServiceContainerAppName string = containerApps.outputs.fineCollectionServiceContainerAppName

@description('The name of the container app for the traffic control service.')
output trafficControlServiceContainerAppName string = containerApps.outputs.trafficControlServiceContainerAppName

@description('The name of the container app for the simulation. If deploySimulationInAcaEnvironment is set to false, this output will be empty.')
output simulationContainerAppName string = containerApps.outputs.simulationContainerAppName

@description('The FQDN of the application gateway.')
output applicationGatewayFqdn string = applicationGateway.outputs.applicationGatewayFqdn

@description('The public IP address of the application gateway.')
output applicationGatewayPublicIp string = applicationGateway.outputs.applicationGatewayPublicIp
