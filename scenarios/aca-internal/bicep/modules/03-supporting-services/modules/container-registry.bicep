targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The name of the container registry.')
param containerRegistryName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('The name of the private endpoint to be created for Azure Container Registry.')
param containerRegistryPrivateEndpointName string

@description('The name of the user assigned identity to be created to pull image from Azure Container Registry.')
param containerRegistryUserAssignedIdentityName string

// ------------------
// VARIABLES
// ------------------

var privateDnsZoneNames = 'privatelink.azurecr.io'
var containerRegistryResourceName = 'registry'

var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]

var spokeVNetIdTokens = split(spokeVNetId, '/')
var spokeSubscriptionId = spokeVNetIdTokens[2]
var spokeResourceGroupName = spokeVNetIdTokens[4]
var spokeVNetName = spokeVNetIdTokens[8]

var containerRegistryPullRoleGuid='7f951dda-4ed3-4680-a7ca-43fe172d538d'

var spokeVNetLinks = [
  {
    vnetName: spokeVNetName
    vnetId: vnetSpoke.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

// ------------------
// RESOURCES
// ------------------

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(spokeSubscriptionId, spokeResourceGroupName)
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnetSpoke
  name: spokePrivateEndpointSubnetName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: { name: 'Premium' }
  properties: {    
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
  }
}

module containerRegistryNetwork '../../../../../shared/bicep/private-networking.bicep' = {
  name: 'containerRegistryNetwork-${uniqueString(containerRegistry.id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneNames
    azServiceId: containerRegistry.id
    privateEndpointName: containerRegistryPrivateEndpointName
    privateEndpointSubResourceName: containerRegistryResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
  }
}

resource containerRegistryUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: containerRegistryUserAssignedIdentityName
  location: location
  tags: tags
}

resource containerRegistryPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, containerRegistry.id, containerRegistryUserAssignedIdentity.id) 
  scope: containerRegistry
  properties: {
    principalId: containerRegistryUserAssignedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', containerRegistryPullRoleGuid)
    principalType: 'ServicePrincipal'
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the container registry.')
output containerRegistryId string = containerRegistry.id

@description('The name of the container registry.')
output containerRegistryName string = containerRegistry.name

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
output containerRegistryUserAssignedIdentityId string = containerRegistryUserAssignedIdentity.id
