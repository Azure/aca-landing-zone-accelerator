targetScope = 'subscription'

param spokeVnetName string
param acaVNetSubnetName string
param spokergName string
param nsgACAName string

param location string = deployment().location
var GWVNetSubnetName = 'appGatewaySubnetName'
var appGatewaySNNSG = 'nsg-apgw-${location}'

resource subnetACA 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
 scope: resourceGroup(spokergName)
  name: '${spokeVnetName}/${acaVNetSubnetName}'
}
//var location  = resourceGroup().location

resource nsgaca 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
scope: resourceGroup(spokergName)
  name: nsgACAName
}

module updateNSG 'modules/vnet/subnet.bicep' = {
scope: resourceGroup(spokergName)
  name: 'updateNSG'
  params: {
    subnetName: acaVNetSubnetName
    vnetName: spokeVnetName
    properties: {
      addressPrefix: subnetACA.properties.addressPrefix
      networkSecurityGroup: {
        id: nsgaca.id
      }
    }
  }
}





resource subnetAppGW 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
 scope: resourceGroup(spokergName)
  name: '${spokeVnetName}/${GWVNetSubnetName}'
}

resource nsgappgw 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
scope: resourceGroup(spokergName)
  name: appGatewaySNNSG
}

module updateGWNSG 'modules/vnet/subnet.bicep' = {
  scope: resourceGroup(spokergName)
  name: 'updateGWNSG'
  params: {
    subnetName: GWVNetSubnetName
    vnetName: spokeVnetName
    properties: {
      addressPrefix: subnetAppGW.properties.addressPrefix
      networkSecurityGroup: {
        id: nsgappgw.id
      }
    }
  }
  dependsOn: [
    updateNSG
  ]
}
