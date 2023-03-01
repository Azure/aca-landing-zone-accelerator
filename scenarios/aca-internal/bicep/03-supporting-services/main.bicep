targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The prefix to be used for all resources created by this template.')
param prefix string = ''
@description('Optional. The suffix to be used for all resources created by this template.')
param suffix string = ''

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

// Azure Container Registry
@description('Optional. The name of the Azure Container Registry. If set, it overrides the name generated by the template.')
param containerRegistryName string = '${replace(prefix, '-', '')}cr${uniqueString(resourceGroup().id)}${replace(suffix, '-', '')}'

@description('Optional. The name of the private endpoint for the Azure Container Registry. If set, it overrides the name generated by the template.')
param containerRegistryPrivateEndpointName string = '${prefix}pep-cr-${uniqueString(resourceGroup().id)}${suffix}'

@description('Optional. The name of the user assigned identity to be created to pull image from Azure Container Registry. If set, it overrides the name generated by the template.')
param containerRegistryUserAssignedIdentityName string = '${prefix}id-cr-${uniqueString(resourceGroup().id)}${suffix}'

// Key Vault
@description('Optional. The name of the Key Vault. If set, it overrides the name generated by the template.')
param keyVaultName string = '${prefix}kv-${uniqueString(resourceGroup().id)}${suffix}'

@description('Optional. The name of the private endpoint for the Key Vault. If set, it overrides the name generated by the template.')
param keyVaultPrivateEndpointName string = '${prefix}pep-kv-${uniqueString(resourceGroup().id)}${suffix}'

@description('Optional. The name of the user assigned identity to be created to pull image from Key Vault. If set, it overrides the name generated by the template.')
param keyVaultUserAssignedIdentityName string = '${prefix}id-kv-${uniqueString(resourceGroup().id)}${suffix}'

// ------------------
// DEPLOYMENT TASKS
// ------------------

module containerRegistry 'modules/azure-container-registry.bicep' = {
  name: 'containerRegistry-${uniqueString(resourceGroup().id)}'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    tags: tags
    spokeVNetId: spokeVNetId
    spokePrivateEndpointSubnetName: spokePrivateEndpointSubnetName
    containerRegistryPrivateEndpointName: containerRegistryPrivateEndpointName
    containerRegistryUserAssignedIdentityName: containerRegistryUserAssignedIdentityName
  }
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault-${uniqueString(resourceGroup().id)}'
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
    spokeVNetId: spokeVNetId
    spokePrivateEndpointSubnetName: spokePrivateEndpointSubnetName
    keyVaultPrivateEndpointName: keyVaultPrivateEndpointName
    keyVaultUserAssignedIdentityName: keyVaultUserAssignedIdentityName
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the container registry.')
output containerRegistryId string = containerRegistry.outputs.containerRegistryId

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
output containerRegistryUserAssignedIdentityId string = containerRegistry.outputs.containerRegistryUserAssignedIdentityId

@description('The resource ID of the key vault.')
output keyVaultId string = keyVault.outputs.keyVaultId

@description('The resource ID of the user assigned managed identity to access the key vault.')
output keyVaultUserAssignedIdentityId string = keyVault.outputs.keyVaultUserAssignedIdentityId
