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
@description('The resource id of the virtual network in which afw is created.')
param afwVNetId string
@description('The log analytics workspace id to which the azure firewall will send logs.')
param logAnalyticsWorkspaceId string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The azure firewall deployment.')
module afw '../../../../../shared/bicep/azureFirewalls/main.bicep' = {
  name: 'afw-deployment'
  params: {
    tags: tags
    location: location
    name: firewallName
    publicIpName: publicIpName
    azureSkuTier: 'Standard'
    vNetId: afwVNetId
    publicIPResourceID: '' //Required only if you want to use an existing public ip address
    additionalPublicIpConfigurations: []
    applicationRuleCollections: []
    networkRuleCollections: []
    natRuleCollections: []
    threatIntelMode: 'Deny'
    diagnosticWorkspaceId: logAnalyticsWorkspaceId
    lock: ''
  }
}
