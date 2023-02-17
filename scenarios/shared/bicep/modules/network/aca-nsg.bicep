@description('Required. Name of the NSG.')
param name string

@description('Azure region where the resources will be deployed in')
param location string

@description('Optional. Tags of the Azure Firewall resource.')
param tags object = {}

var azcloud =  'AzureCloud.${location}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    //securityRules: securityRules
    securityRules: [   
      {
        name: 'AllowhttpInbound'
        properties: {
          priority: 100
          protocol: '*'
          destinationPortRanges:[
            '443'
            '80'
          ]
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }              
      }                
        {
          name: 'AllowhttpOutbound'
          properties: {
            priority: 110
            protocol: '*'
            destinationPortRanges:[
              '443'
              '80'
            ]
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
          }              
        }                                                         
        {
          name: 'AllowCommunicationToControlPlane'
          properties: {
            priority: 120
            protocol: '*'
            destinationPortRanges: [  
              '5671'
              '5672'
            ]
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
          }              
        }                     
        {
          name: 'AllowAccesstoNTPServer'
          properties: {
            priority: 130
            protocol: 'UDP'
            destinationPortRange: '123'
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
          }              
        }
        {
          name: 'AllowInternalAKSConnection'
          properties: {
            priority: 140
            protocol: 'UDP'
            destinationPortRanges: [
              '1194'
              '9000'
            ]
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: azcloud
          }              
        }
        {
          name: 'AllowAccesstoAzureMonitor'
          properties: {
            priority: 150
            protocol: 'TCP'
            destinationPortRange: '443'
            access: 'Allow'
            direction: 'Outbound'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'AzureMonitor'
          }              
        }                                                                
  ]
  }
}
output nsgID string = nsg.id
