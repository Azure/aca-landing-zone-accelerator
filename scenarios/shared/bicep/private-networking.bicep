targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('Resource Id of the subnet, where the private endpoint and NIC will be attached to')
param subnetId string

@description('The Resource Id of Private Link Service. The Resource Id of the Az Resource that we need to attach the Private Endpoint to')
param azServiceId string

@description('Name of the Private DNS Zone Service. For az private endpoints you might find info here: https://learn.microsoft.com/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration')
param azServicePrivateDnsZoneName string

@description('Resource name of the Private Endpoint')
param privateEndpointName string

@description('The resource that the Private Endpoint will be attached to, as shown in https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource')
param privateEndpointSubResourceName string

@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

// ------------------
// RESOURCES
// ------------------

module privateDnsZone 'private-dns-zone.bicep' = {
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: 'privateDnsZoneDeployment-${uniqueString(azServiceId, privateEndpointSubResourceName)}'
  params: {
    name: azServicePrivateDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
  }
}

module privateEndpoint 'private-endpoint.bicep' = {
  name: 'privateEndpointDeployment-${uniqueString(azServiceId, privateEndpointSubResourceName)}'
  params: {
    name: privateEndpointName
    location: location
    privateDnsZonesId: privateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: azServiceId
    snetId:  subnetId
    subresource: privateEndpointSubResourceName
  }
}
