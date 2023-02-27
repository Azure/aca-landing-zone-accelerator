targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The name of the Key Vault.')
param keyVaultName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string
@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('The name of the private endpoint to be created for Key Vault.')
param keyVaultPrivateEndpointName string

@description('The name of the user assigned identity with Key Vault reader role.')
param keyVaultUserAssignedIdentityName string

// ------------------
//    VARIABLES
// ------------------

var privateDnsZoneNames = 'privatelink.vaultcore.azure.net'

var keyVaultResourceName = 'vault'

var spokeVNetIdTokens = split(spokeVNetId, '/')
var spokeSubscriptionId = spokeVNetIdTokens[2]
var spokeResourceGroupName = spokeVNetIdTokens[4]
var spokeVNetName = spokeVNetIdTokens[8]

var keyvaultReaderRoleGuid = '21090545-7ca7-4776-b22c-e363652d74d2'

// ------------------
// DEPLOYMENT TASKS
// ------------------

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location  
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    enablePurgeProtection: null  // It seems that you cannot set it to False even the first time. workaround is not to set it at all: https://github.com/Azure/bicep/issues/5223
    publicNetworkAccess: 'Disabled'
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
  }
}

module keyVaultNetwork '../../modules/private-networking.bicep' = {
  name: 'keyVaultNetwork'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneNames
    azServiceId: keyVault.id
    privateEndpointName: keyVaultPrivateEndpointName
    privateEndpointSubResourceName: keyVaultResourceName
    spokeSubscriptionId: spokeSubscriptionId
    spokeResourceGroupName: spokeResourceGroupName
    spokeVirtualNetworkName: spokeVNetName
    spokeVirtualNetworkPrivateEndpointSubnetName: spokePrivateEndpointSubnetName
  }
}

resource keyVaultUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: keyVaultUserAssignedIdentityName
  location: location
  tags: tags
}

resource keyVaultReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, keyVault.id, keyVaultUserAssignedIdentity.id) 
  scope: keyVault
  properties: {
    principalId: keyVaultUserAssignedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyvaultReaderRoleGuid)
    principalType: 'ServicePrincipal'
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the key vault.')
output keyVaultId string = keyVault.id
@description('The name of the key vault.')
output keyVaultName string = keyVault.name
@description('The resource ID of the user assigned managed identity to access the key vault.')
output keyVaultUserAssignedIdentityId string = keyVaultUserAssignedIdentity.id
