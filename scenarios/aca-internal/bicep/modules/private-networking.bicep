targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('Resource ID of the subnet, where the private endpoint and NIC will be attached to')
param subnetId string

// param spokeSubscriptionId string
// param spokeResourceGroupName string
// param spokeVirtualNetworkName string
// @description('The name of the subnet for supporting services of the spoke')
// param spokeVirtualNetworkPrivateEndpointSubnetName string

@description('TODO: Add desription')
param azServiceId string

@description('TODO: Add desription')
param azServicePrivateDnsZoneName string

@description('TODO: Add desription')
param privateEndpointName string

@description('TODO: Add desription')
param privateEndpointSubResourceName string

@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

// ------------------
// RESOURCES
// ------------------

module privateDnsZone 'private-dns-zone.bicep' = {
  name: 'privateDnsZoneDeployment-${uniqueString(azServiceId)}'
  params: {
    name: azServicePrivateDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
  }
}

module privateEndpoint 'private-endpoint.bicep' = {
  name: 'privateEndpointDeployment-${uniqueString(azServiceId)}'
  params: {
    name: privateEndpointName
    location: location
    privateDnsZonesId: privateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: azServiceId
    snetId:  subnetId
    subresource: privateEndpointSubResourceName
  }
}
