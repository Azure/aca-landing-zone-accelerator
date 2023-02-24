@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet for supporting services of the spoke')
param servicesSubnetName string

@description('The name of the service bus namespace.')
param serviceBusName string = 'eslz-sb-${uniqueString(resourceGroup().id)}'
@description('The name of the service bus topic.')
param serviceBusTopicName string
@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string
@description('The name of service bus\' private endpoint.')
param serviceBusPrivateEndpointName string = 'sb-pvt-ep'
@description('The name of service bus\' private dns zone.')
param serviceBusPrivateDNSZoneName string = 'sb-pvt-dns'
@description('The name of service bus\' private dns zone link to spoke VNET.')
param serviceBusPrivateDNSLinkSpokeName string = 'sb-pvt-dns-link-spoke'

@description('The name of the service for the fine collection service. This will be used to create the topic subscription')
param fineCollectionServiceName string

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${spokeVNet.name}/${servicesSubnetName}'
}

// Public access is only available in the preview
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusName
  location: location
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

module serviceBusPrivateEndpoint '../../../../bicep/modules/vnet/privateendpoint.bicep' = {
  name: serviceBusPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'namespace'
    ]
    privateEndpointName: serviceBusPrivateEndpointName
    privatelinkConnName: '${serviceBusPrivateEndpointName}-conn'
    resourceId: serviceBusNamespace.id
    subnetid: servicesSubnet.id
  }
}

module serviceBusPrivateDNSZone '../../../../bicep/modules/vnet/privatednszone.bicep' = {
  name: serviceBusPrivateDNSZoneName
  params: {
     privateDNSZoneName: 'privatelink.servicebus.windows.net'
  }
}

module serviceBusPrivateDNSZoneLinkSpoke '../../../../bicep/modules/vnet/privatednslink.bicep' = {
  name: serviceBusPrivateDNSLinkSpokeName
  params: {
    privateDnsZoneName: serviceBusPrivateDNSZone.outputs.privateDNSZoneName
    vnetId: spokeVNet.id
    linkname: 'spoke'
  }
}

module serviceBusPrivateEndpointDnsSetting '../../../../bicep/modules/vnet/privatedns.bicep' = {
  name: 'sb-pvtep-dns'
  params: {
    privateDNSZoneId: serviceBusPrivateDNSZone.outputs.privateDNSZoneId
    privateEndpointName: serviceBusPrivateEndpoint.outputs.privateEndpointName
  }
}

@description('The name of the service bus namespace.')
output serviceBusName string = serviceBusNamespace.name
@description('The name of the service bus topic.')
output serviceBusTopicName string = serviceBusTopic.name
@description('The name of the service bus topic\'s authorization rule.')
output serviceBusTopicAuthorizationRuleName string = serviceBusTopicAuthRule.name
