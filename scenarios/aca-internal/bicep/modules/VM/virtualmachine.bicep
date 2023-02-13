
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




resource jumpBoxNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (osType == 'linux') {
  name: jumpBoxSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}


resource subnetVM 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetHubName}/${VMSubnetName}'
}

module updateVmNSG '../vnet/subnet.bicep' = if (osType == 'linux') {
  name: 'updateVmNSG'
  params: {
    subnetName: VMSubnetName
    vnetName: vnetHubName
    properties: {
     addressPrefix: subnetVM.properties.addressPrefix
      networkSecurityGroup: {
        id: jumpBoxNSG.id
      }
    }
  }
  dependsOn: [  
  ]
}


module jbnic '../vnet/nic.bicep' = if (osType == 'linux') {
  name: 'jbnic'
  params: {
    location: location
    subnetId: subnetVM.id
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


