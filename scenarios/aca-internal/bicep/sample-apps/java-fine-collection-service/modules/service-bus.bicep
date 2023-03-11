targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

@description('The name of service bus\' private endpoint.')
param serviceBusPrivateEndpointName string

@description('The name of the service for the fine collection service. The name is use as Dapr App ID and as the name of service bus topic subscription.')
param fineCollectionServiceName string

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

// Public access is only available in the preview
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusName
  location: location
  tags: tags
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }

  properties: {
    disableLocalAuth: false
    publicNetworkAccess: 'Disabled'
  }
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' = {
  name: serviceBusTopicName
  parent: serviceBusNamespace
}

resource serviceBusTopicAuthRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' = {
  name: serviceBusTopicAuthorizationRuleName
  parent: serviceBusTopic
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource serviceBusTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: fineCollectionServiceName
  parent: serviceBusTopic
}

module serviceBusNetworking '../../../../../shared/bicep/private-networking.bicep' = {
  name: 'serviceBusNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneName
    azServiceId: serviceBusNamespace.id
    privateEndpointName: serviceBusPrivateEndpointName
    privateEndpointSubResourceName: serviceBusNamespaceResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of the service bus namespace.')
output serviceBusName string = serviceBusNamespace.name

@description('The name of the service bus topic.')
output serviceBusTopicName string = serviceBusTopic.name

@description('The name of the service bus topic\'s authorization rule.')
output serviceBusTopicAuthorizationRuleName string = serviceBusTopicAuthRule.name
