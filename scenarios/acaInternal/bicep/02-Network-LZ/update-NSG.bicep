targetScope = 'subscription'

param spokeVnetName string
param acaVNetSubnetName string
param rgName string
param nsgACAName string

resource subnetACA 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  scope: resourceGroup(rgName)
  name: '${spokeVnetName}/${acaVNetSubnetName}'
}


resource nsgaca 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  scope: resourceGroup(rgName)
  name: nsgACAName
}

module updateNSG 'modules/vnet/subnet.bicep' = {
  scope: resourceGroup(rgName)
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








// module updateNSGUDR 'modules/vnet/subnet.bicep' = {
//   scope: resourceGroup(rg.name)
//   name: 'updateNSGUDR'
//   params: {
//     subnetName: aksVNetSubnetName
//     vnetName: vnetSpokeName
//     properties: {
//       addressPrefix: aksSubnet.properties.addressPrefix
//       routeTable: {
//         id: routetable.outputs.routetableID
//       }
//       networkSecurityGroup: {
//         id: nsgakssubnet.outputs.nsgID
//       }
//     }
//   }
// }
