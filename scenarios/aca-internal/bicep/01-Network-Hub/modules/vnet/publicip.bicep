param publicipName string
param publicipsku object
param publicipproperties object
param location string = resourceGroup().location
param availabilityZones array
param deploybastion bool

resource publicip 'Microsoft.Network/publicIPAddresses@2021-02-01' = if(deploybastion) {
  name: publicipName
  location: location
  sku: publicipsku
  properties: publicipproperties
  zones: !empty(availabilityZones) ? availabilityZones : null
}
output publicipId string = publicip.id
