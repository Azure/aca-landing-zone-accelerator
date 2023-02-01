param bastionpipId string
param subnetId string
param location string = resourceGroup().location
param deploybastion bool

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = if(deploybastion) {
  name: 'bastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          publicIPAddress: {
            id: bastionpipId
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
