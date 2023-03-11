targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location
@description('The name of the bastion host to create.')
param bastionName string
@description('The name of the virtual network in which bastion subnet is created.')
param bastionVNetName string
@description('The name of the bastion subnet.')
param bastionSubnetName string
@description('CIDR of the bastion subnet.')
param bastionSubnetAddressPrefix string
@description('The name of the network security group to create.')
param bastionNetworkSecurityGroupName string
@description('The name of the public IP address to create.')
param bastionPublicIpName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

// ------------------
// RESOURCES
// ------------------

//TODO: This (randomly) causes 'AzureAsyncOperationWaiting' resource operation completed with terminal provisioning state 'Failed' > AnotherOperationInProgress > Another operation on this or dependent resource is in progress. To retrieve status of the operation use uri
resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${bastionVNetName}/${bastionSubnetName}'
  properties: {
    addressPrefix: bastionSubnetAddressPrefix
    networkSecurityGroup: {
      id: bastionNetworkSecurityGroup.id
    }
  }
}

resource bastionPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: bastionPublicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          publicIPAddress: {
            id: bastionPip.id
          }
          subnet: {
            id: bastionSubnet.id
          }
        }
      }
    ]
  }
  dependsOn: [
    bastionNetworkSecurityGroup
  ]
}

resource bastionNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: bastionNetworkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 120
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 130
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 140
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInbound'
        properties: {
          priority: 150
          protocol: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          priority: 100
          protocol: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          priority: 110
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          priority: 120
          protocol: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          priority: 130
          protocol: '*'
          destinationPortRange: '80'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}
