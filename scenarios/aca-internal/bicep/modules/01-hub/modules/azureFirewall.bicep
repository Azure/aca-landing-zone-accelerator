targetScope = 'resourceGroup'
// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string
@description('The name of the azure firewall to create.')
param firewallName string
@description('The name for the public ip address of the azure firewall.')
param publicIpName string
@description('The Name of the virtual network in which afw is created.')
param afwVNetName string
@description('The address prefix of the subnet in which the azure firewall will be created.')
param addressPrefix string
@description('The log analytics workspace id to which the azure firewall will send logs.')
param logAnalyticsWorkspaceId string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

var applicationRuleCollections = [
  {
    name: 'allow-aca-rules'
    properties: {
      action: {
        type: 'allow'
      }
      priority: 110
      rules: [
        {
          name: 'allow-aca-controlplane'
          protocols: [
            {
              port: '80'
              protocolType: 'HTTP'
            }
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            '*'
          ]
          targetFqdns: [
            'mcr.microsoft.com'
            '*.data.mcr.microsoft.com'
            '*.blob.core.windows.net' //NOTE: If you use ACR the endpoint must be added as well.
          ]
        }
      ]
    }
  }
]

resource hubVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: afwVNetName
}

resource azFWSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'AzureFirewallSubnet'
  parent: hubVnet
  properties: {
    addressPrefix: addressPrefix
  }
}

@description('The azure firewall deployment.')
module afw '../../../../../shared/bicep/azureFirewalls/main.bicep' = {
  name: 'afw-deployment'
  params: {
    tags: tags
    location: location
    name: firewallName
    publicIpName: publicIpName
    azureSkuTier: 'Standard'
    vNetId: hubVnet.id
    publicIPResourceID: '' //Required only if you want to use an existing public ip address
    additionalPublicIpConfigurations: []
    applicationRuleCollections: applicationRuleCollections
    networkRuleCollections: []
    natRuleCollections: []
    threatIntelMode: 'Deny'
    diagnosticWorkspaceId: logAnalyticsWorkspaceId
    lock: ''
  }
}

output afwPrivateIp string = afw.outputs.privateIp
output afwId string = afw.outputs.resourceId
