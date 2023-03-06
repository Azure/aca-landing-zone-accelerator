targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

param workloadName string

param environmentName string

param locationShortName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

// Azure Container Registry
@minLength(5)
@maxLength(50)
@description('Optional. The name of the Azure Container Registry. If set, it overrides the name generated by the template.')
param containerRegistryName string = toLower(take('cr${replace(workloadName, '-', '')}${take(uniqueString(resourceGroup().id), 5)}${replace(environmentName, '-', '')}${replace(environmentName, '-', '')}${replace(locationShortName, '-', '')}', 50))

@description('Optional. The name of the private endpoint for the Azure Container Registry. If set, it overrides the name generated by the template.')
param containerRegistryPrivateEndpointName string = 'pep-${toLower(take('cr${replace(workloadName, '-', '')}${take(uniqueString(resourceGroup().id), 5)}${replace(environmentName, '-', '')}${replace(environmentName, '-', '')}${replace(locationShortName, '-', '')}', 50))}'

@description('Optional. The name of the user assigned identity to be created to pull image from Azure Container Registry. If set, it overrides the name generated by the template.')
param containerRegistryUserAssignedIdentityName string = 'id-${toLower(take('cr${replace(workloadName, '-', '')}${take(uniqueString(resourceGroup().id), 5)}${replace(environmentName, '-', '')}${replace(environmentName, '-', '')}${replace(locationShortName, '-', '')}', 50))}'

// Key Vault
@minLength(3)
@maxLength(24)
@description('Optional. The name of the Key Vault. If set, it overrides the name generated by the template.')
param keyVaultName string = take('kv-${workloadName}-${take(uniqueString(resourceGroup().id), 5)}-${environmentName}-${locationShortName}', 24)

@description('Optional. The name of the private endpoint for the Key Vault. If set, it overrides the name generated by the template.')
param keyVaultPrivateEndpointName string = 'pep-${take('kv-${workloadName}-${take(uniqueString(resourceGroup().id), 5)}-${environmentName}-${locationShortName}', 24)}'

@description('Optional. The name of the user assigned identity to be created to pull image from Key Vault. If set, it overrides the name generated by the template.')
param keyVaultUserAssignedIdentityName string = 'id-${take('kv-${workloadName}-${take(uniqueString(resourceGroup().id), 5)}-${environmentName}-${locationShortName}', 24)}'

// ------------------
// RESOURCES
// ------------------

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry-${uniqueString(resourceGroup().id)}'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    tags: tags
    spokeVNetId: spokeVNetId
    hubVNetId: hubVNetId
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
    hubVNetId: hubVNetId
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
