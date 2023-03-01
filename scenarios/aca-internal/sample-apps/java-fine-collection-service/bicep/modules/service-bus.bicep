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

@description('The name of the service bus namespace.')
param serviceBusName string

@description('The name of the service bus topic.')
param serviceBusTopicName string

@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string

@description('The name of service bus\' private endpoint.')
param serviceBusPrivateEndpointName string

@description('The name of the service for the fine collection service. This will be used to create the topic subscription')
param fineCollectionServiceName string

// ------------------
//    VARIABLES
// ------------------

var privateDnsZoneName = 'privatelink.servicebus.windows.net'

var serviceBusNamespaceResourceName = 'namespace'

// ------------------
// DEPLOYMENT TASKS
// ------------------

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

module serviceBusNetworking '../../../../bicep/modules/private-networking.bicep' = {
  name: 'serviceBusNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneName
    azServiceId: serviceBusNamespace.id
    privateEndpointName: serviceBusPrivateEndpointName
    privateEndpointSubResourceName: serviceBusNamespaceResourceName
    spokeSubscriptionId: subscription().subscriptionId
    spokeResourceGroupName: resourceGroup().name
    spokeVirtualNetworkName: spokeVNet.name
    spokeVirtualNetworkPrivateEndpointSubnetName: spokePrivateEndpointSubnet.name
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
