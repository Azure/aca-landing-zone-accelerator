targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@minLength(2)
@maxLength(10)
@description('The name of the workloard that is being deployed. Up to 10 characters long.')
param workloadName string

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa") Up to 8 characters long.')
@maxLength(8)
param environment string

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

// ------------------
// RESOURCES
// ------------------

module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('03-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}

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

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the container registry.')
output containerRegistryId string = containerRegistry.outputs.containerRegistryId

@description('The name of the container registry.')
output containerRegistryName string = containerRegistry.outputs.containerRegistryName

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
output containerRegistryUserAssignedIdentityId string = containerRegistry.outputs.containerRegistryUserAssignedIdentityId

@description('The resource ID of the key vault.')
output keyVaultId string = keyVault.outputs.keyVaultId

@description('The name of the key vault.')
output keyVaultName string = keyVault.outputs.keyVaultName

@description('The resource ID of the user assigned managed identity to access the key vault.')
output keyVaultUserAssignedIdentityId string = keyVault.outputs.keyVaultUserAssignedIdentityId
