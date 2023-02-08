param subnetId string
param publicKey string
param vmSize string
param location string = resourceGroup().location
param adminUsername string
param adminPassword string
param osType string
//param script64 string
var jumpBoxSNNSG = 'nsg-jbox-${location}'
param VMSubnetName string
param vnetHubName string
param vmSubnetAddressPrefix string



resource jumpBoxNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (osType == 'linux') {
  name: jumpBoxSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}
var properties  = {
    addressPrefix: vmSubnetAddressPrefix
    networkSecurityGroup: {
      id: jumpBoxNSG.id
    }
  
}
module subnet '../vnet/subnet.bicep' = {
  name: VMSubnetName
  params: {
   properties: properties
   vnetName: vnetHubName
   subnetName:VMSubnetName
  }
  dependsOn:[
  ]
}


module jbnic '../vnet/nic.bicep' = {
  name: 'jbnic'
  params: {
    location: location
    subnetId: subnet.outputs.subnetId
  }
  dependsOn:[
  ]
}

resource jumpbox 'Microsoft.Compute/virtualMachines@2021-03-01' = if (osType == 'linux') {
  name: 'jumpbox'
  location: location
  properties: {
    osProfile: {
      computerName: 'jumpbox'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jbnic.outputs.nicId
        }
      ]
    }
  }
}


