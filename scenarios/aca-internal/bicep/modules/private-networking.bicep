targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------
param spokeSubscriptionId string
param spokeResourceGroupName string
param spokeVirtualNetworkName string
@description('The name of the subnet for supporting services of the spoke')
param spokeVirtualNetworkPrivateEndpointSubnetName string

param azServiceId string
param azServicePrivateDnsZoneName string
param privateEndpointName string
param privateEndpointSubResourceName string

@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

// ------------------
// DEPLOYMENT TASKS
// ------------------

resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  scope: resourceGroup(spokeSubscriptionId, spokeResourceGroupName)
  name: spokeVirtualNetworkName

  resource privateEndpointSubnet 'subnets@2021-02-01' existing = {
    name: spokeVirtualNetworkPrivateEndpointSubnetName
  }
}

module privateDnsZone 'private-dns-zone.bicep' = {
  name: 'privateDnsZoneDeployment-${uniqueString(azServiceId)}'
  params: {
    name: azServicePrivateDnsZoneName
    virtualNetworkLinks: [
      {
        vnetName: spokeVirtualNetwork.name
        vnetId: spokeVirtualNetwork.id
        registrationEnabled: false
      }
    ]
  }
}

module privateEndpoint 'private-endpoint.bicep' = {
  name: 'privateEndpointDeployment-${uniqueString(azServiceId)}'
  params: {
    name: privateEndpointName
    location: location
    privateDnsZonesId: privateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: azServiceId
    snetId:  spokeVirtualNetwork::privateEndpointSubnet.id
    subresource: privateEndpointSubResourceName
  }
}
