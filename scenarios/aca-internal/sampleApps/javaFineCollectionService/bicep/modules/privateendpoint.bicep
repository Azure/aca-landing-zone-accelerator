param privateEndpointName string
param region string
param tags object = {}

param snetID string
param pLinkServiceID string

param serviceLinkGroupIds array

param privateDnsZonesId string


//Create private endpoint and private link for the specific service(pLinkServiceID) 
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: region
  tags: tags
  properties: {
    subnet: {
      id: snetID
    }
    privateLinkServiceConnections: [
      {
        name: 'pl-${privateEndpointName}'
        properties: {
          privateLinkServiceId: pLinkServiceID
          groupIds: serviceLinkGroupIds
        }
      }
    ]
  }
}

//Register private endpoint in private dns zone
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpoint.name}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZonesId
        }
      }
    ]
  }
}
