targetScope = 'resourceGroup'


param vnetName string
param tags object = {}
param location string = resourceGroup().location
param vnetAddressPrefixes array
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: subnets
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
