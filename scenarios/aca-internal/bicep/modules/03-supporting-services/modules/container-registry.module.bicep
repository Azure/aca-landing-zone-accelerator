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

@description(' Name of the hub vnet')
param hubVNetName string 

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('The name of the private endpoint to be created for Azure Container Registry.')
param containerRegistryPrivateEndpointName string

@description('The name of the user assigned identity to be created to pull image from Azure Container Registry.')
param containerRegistryUserAssignedIdentityName string

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional, default value is true. If true, any resources that support AZ will be deployed in all three AZ. However if the selected region is not supporting AZ, this parameter needs to be set to false.')
param deployZoneRedundantResources bool = true



// ------------------
// VARIABLES
// ------------------

var privateDnsZoneNames = 'privatelink.azurecr.io'
var containerRegistryResourceName = 'registry'

var spokeVNetIdTokens = split(spokeVNetId, '/')
var spokeSubscriptionId = spokeVNetIdTokens[2]
var spokeResourceGroupName = spokeVNetIdTokens[4]
var spokeVNetName = spokeVNetIdTokens[8]

var containerRegistryPullRoleGuid='7f951dda-4ed3-4680-a7ca-43fe172d538d'

// Only include hubvnet to the mix if a valid hubvnet id is provided
var spokeVNetLinks = concat(
  [
    {
      vnetName: spokeVNetName
      vnetId: vnetSpoke.id
      registrationEnabled: false
    }
  ],
  !empty(hubVNetName) ? [
    {
      vnetName: hubVNetName
      vnetId: hubVNetId
      registrationEnabled: false
    }
  ] : []
)

// ------------------
// RESOURCES
// ------------------

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(spokeSubscriptionId, spokeResourceGroupName)
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnetSpoke
  name: spokePrivateEndpointSubnetName
}

module containerRegistry '../../../../../shared/bicep/container-registry.bicep' = {
  name: take('containerRegistryNameDeployment-${deployment().name}', 64)
  params: {
    location: location
    tags: tags    
    name: containerRegistryName
    acrSku: 'Premium'
    zoneRedundancy: deployZoneRedundantResources ? 'Enabled' : 'Disabled'
    acrAdminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    diagnosticWorkspaceId: diagnosticWorkspaceId
    agentPoolSubnetId: spokePrivateEndpointSubnet.id
  }
}

module containerRegistryNetwork '../../../../../shared/bicep/network/private-networking.bicep' = {
  name:take('containerRegistryNetworkDeployment-${deployment().name}', 64)
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneNames
    azServiceId: containerRegistry.outputs.resourceId
    privateEndpointName: containerRegistryPrivateEndpointName
    privateEndpointSubResourceName: containerRegistryResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
    vnetHubResourceId: hubVNetId
  }
}

resource containerRegistryUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: containerRegistryUserAssignedIdentityName
  location: location
  tags: tags
}


module containerRegistryPullRoleAssignment '../../../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: take('containerRegistryPullRoleAssignmentDeployment-${deployment().name}', 64)
  params: {
    name: 'ra-containerRegistryPullRoleAssignment'
    principalId: containerRegistryUserAssignedIdentity.properties.principalId
    resourceId: containerRegistry.outputs.resourceId
    roleDefinitionId: containerRegistryPullRoleGuid
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the container registry.')
output containerRegistryId string = containerRegistry.outputs.resourceId

@description('The name of the container registry.')
output containerRegistryName string = containerRegistry.outputs.name

@description('The name of the container registry login server.')
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
output containerRegistryUserAssignedIdentityId string = containerRegistryUserAssignedIdentity.id

@description('The name of Azure container registry agent pool name to build images')
output containerRegistryAgentPoolName string = containerRegistry.outputs.agentPoolName


