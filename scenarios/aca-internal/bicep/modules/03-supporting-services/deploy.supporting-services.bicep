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

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

// Hub
@description('The resource ID of the existing hub virtual network.')
param hubVNetId string

// Spoke
@description('The resource ID of the existing spoke virtual network to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the existing subnet in the spoke virtual to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('Deploy Redis cache premium SKU')
param deployRedisCache bool = true

// ------------------
// RESOURCES
// ------------------

@description('User-configured naming rules')
module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('03-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}

@description('Azure Container Registry, where all workload images should be pulled from.')
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry-${uniqueString(resourceGroup().id)}'
  params: {
    containerRegistryName: naming.outputs.resourcesNames.containerRegistry
    location: location
    tags: tags
    spokeVNetId: spokeVNetId
    hubVNetId: hubVNetId
    spokePrivateEndpointSubnetName: spokePrivateEndpointSubnetName
    containerRegistryPrivateEndpointName: naming.outputs.resourcesNames.containerRegistryPep
    containerRegistryUserAssignedIdentityName: naming.outputs.resourcesNames.containerRegistryUserAssignedIdentity
  }
}

@description('Azure Key Vault used to hold items like TLS certs and application secrets that your workload will need.')
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault-${uniqueString(resourceGroup().id)}'
  params: {
    keyVaultName: naming.outputs.resourcesNames.keyVault
    location: location
    tags: tags
    spokeVNetId: spokeVNetId
    hubVNetId: hubVNetId
    spokePrivateEndpointSubnetName: spokePrivateEndpointSubnetName
    keyVaultPrivateEndpointName: naming.outputs.resourcesNames.keyVaultPep
    keyVaultUserAssignedIdentityName: naming.outputs.resourcesNames.keyVaultUserAssignedIdentity
  }
}

@description('The log sink for Azure Diagnostics')
module logAnalyticsWorkspace '../../../../shared/bicep/log-analytics-ws.bicep' = {
  name: take('logAnalyticsWs-${uniqueString(resourceGroup().id)}', 64)
  params: {
    location: location
    name: naming.outputs.resourcesNames.logAnalyticsWorkspace
  }
}

module redisCache 'modules/redisCache.bicep' = if (deployRedisCache) {
  name: 'redisCache-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    redisName: naming.outputs.resourcesNames.redisCache
    logAnalyticsWsId: logAnalyticsWorkspace.outputs.logAnalyticsWsId
    keyVaultName: keyVault.outputs.keyVaultName
    spokeVNetId: spokeVNetId
    hubVNetId: hubVNetId
    spokePrivateEndpointSubnetName: spokePrivateEndpointSubnetName
    redisCachePrivateEndpointName: naming.outputs.resourcesNames.redisCachePep
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the Azure Container Registry.')
output containerRegistryId string = containerRegistry.outputs.containerRegistryId

@description('The name of the Azure Container Registry.')
output containerRegistryName string = containerRegistry.outputs.containerRegistryName

@description('The resource ID of the user-assigned managed identity for the Azure Container Registry to be able to pull images from it.')
output containerRegistryUserAssignedIdentityId string = containerRegistry.outputs.containerRegistryUserAssignedIdentityId

@description('The resource ID of the Azure Key Vault.')
output keyVaultId string = keyVault.outputs.keyVaultId

@description('The name of the Azure Key Vault.')
output keyVaultName string = keyVault.outputs.keyVaultName

@description('The resource ID of the user-assigned managed identity to read from Azure Key Vault.')
output keyVaultUserAssignedIdentityId string = keyVault.outputs.keyVaultUserAssignedIdentityId

@description('The resource ID of the Azure Log Analytics Workspace.')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.logAnalyticsWsId

@description('The secret name to retrieve the connection string from KeyVault')
output redisCacheSecretKey string = (deployRedisCache)? redisCache.outputs.redisCacheSecretKey : ''
