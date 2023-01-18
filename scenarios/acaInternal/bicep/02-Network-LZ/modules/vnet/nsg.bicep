param nsgName string
param securityRules array = []
param location string = resourceGroup().location
var azcloud =  'AzureCloud.${location}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  properties: {
    //securityRules: securityRules
    securityRules: [                    
        {
          name: 'AllowhttpOutbound'
          properties: {
            priority: 100
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
