//TODO:  Not ready, maybe not needed

@description('Required. Name of the appGW NSG.')
param nsgAppGwName string

@description('Required. Name of the ACA Environment NSG.')
param nsgAcaName string 

@description('Azure region where the resources will be deployed in')
param location string

@description('Optional. Tags of the Azure Firewall resource.')
param tags object = {}

param vnetName string
param snetAppGwName string
param ssnetAcaEnvName string 



module appGwNsg 'network/app-gw-nsg.bicep' = {
  name: 'appGwNsgDeployment'
  params: {
    name: nsgAppGwName
    location: location
    tags: tags
  }
}

module acaEnvNsg 'network/aca-nsg.bicep' = {
  name: 'acaEnvNsgDeployment'
  params: {
    name: nsgAcaName
    location: location
    tags: tags
  }
}


// resource attachAppGwNsg 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
//   name: '${vnetName}/${snetAppGwName}'
//   properties: {
//     //addressPrefix: subnetAddressPrefix
//     networkSecurityGroup: {
//       id: appGwNsg.outputs.nsgID
//     }
//   }
// }

output appGwNsgResourceId string = appGwNsg.outputs.nsgID
output acaEnvNsgResourceId string = acaEnvNsg.outputs.nsgID
