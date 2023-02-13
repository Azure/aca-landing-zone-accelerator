@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet for supporting services of the spoke')
param servicesSubnetName string

@description('The name of the user managed identity used to access the keyvault.')
param userManagedIdentityName string

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

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${spokeVNet.name}/${servicesSubnetName}'
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userManagedIdentityName
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

//enable send/receive to aca user assigned identity
resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, '${acaIdentity.name}', '090c5cfd-751d-490a-894a-3ce6f1109419')
  properties: {
    principalId: acaIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')//Azure Service Bus Data Owner
  }
  
  scope: serviceBusNamespace
}

@description('The name of the service bus namespace.')
output serviceBusName string = serviceBusNamespace.name
@description('The name of the service bus topic.')
output serviceBusTopicName string = serviceBusTopic.name
@description('The name of the service bus topic\'s authorization rule.')
output serviceBusTopicAuthorizationRuleName string = serviceBusTopicAuthRule.name
