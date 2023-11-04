targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of service bus\' private endpoint.')
param serviceBusPrivateEndpointName string

@description('The resource ID of the Log Analytics Workspace.')
param workspaceId string

@description('The resource ID of the ACA managed identity.')
param managedIdentityPrincipalId string

// ------------------
// VARIABLES
// ------------------
var spokeVNetLinks = [
  {
    vnetName: spokeVNetName
    vnetId: spokeVNet.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var privateDnsZoneName = 'privatelink.servicebus.windows.net'
var serviceBusNamespaceResourceName = 'namespace'

var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]
var roleIds = [
  '090c5cfd-751d-490a-894a-3ce6f1109419' // Azure Service Bus Data Owner
]

// ------------------
// RESOURCES
// ------------------

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: spokePrivateEndpointsSubnetName
  parent: spokeVNet
}

module serviceBusNamespace '../../../../../shared/bicep/service-bus.bicep' = {
  name: 'jobs-sb-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    tags: tags
    name: serviceBusName
    skuName: 'Premium'
    workspaceId: workspaceId
    publicNetworkAccess: 'Disabled'
    queueNames: [ 'parameters', 'results' ]
  }
}

// Get a reference to servicebus namespace
resource servicebus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
}

// Grant permissions to the principalID to specific role to servicebus
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleId in roleIds : {
  name: guid(servicebus.id, roleId, managedIdentityPrincipalId)
  scope: servicebus
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}]

module serviceBusNetworking '../../../../../shared/bicep/network/private-networking.bicep' = {
  name: 'serviceBusNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneName
    azServiceId: serviceBusNamespace.outputs.id
    privateEndpointName: serviceBusPrivateEndpointName
    privateEndpointSubResourceName: serviceBusNamespaceResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
    vnetHubResourceId: hubVNetId
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the service bus namespace.')
output serviceBusName string = serviceBusNamespace.outputs.name
@description('The connection string of the service bus namespace.')
output connectionString string = serviceBusNamespace.outputs.connectionString
@description('The queue names of the service bus namespace.')
output queues array = serviceBusNamespace.outputs.queues
@description('The topic names of the service bus namespace.')
output topics array = serviceBusNamespace.outputs.topics
