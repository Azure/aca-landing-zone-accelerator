targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the external Azure Storage Account.')
param storageAccountName string

@description('The name of the external Queue in Azure Storage.')
param externalTasksQueueName string

@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of blob private endpoint.')
param blobPrivateEndpointName string

@description('The name of queue private endpoint.')
param queuePrivateEndpointName string

// ------------------
// VARIABLES
// ------------------
var spokeVNetLinks = [
  {
    vnetName: spokeVNetName
    vnetId: spokeVNet.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]

var privateBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'

// ------------------
// RESOURCES
// ------------------

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: spokePrivateEndpointsSubnetName
  parent: spokeVNet
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  tags: tags
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
  }
}

resource storageQueuesService 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource externalQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
  name: externalTasksQueueName
  parent: storageQueuesService
}

module storageAccountBlobNetworking '../../../../../shared/bicep/private-networking.bicep' = {
  name: 'storageAccountBlobNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateBlobDnsZoneName
    azServiceId: storageAccount.id
    privateEndpointName: blobPrivateEndpointName
    privateEndpointSubResourceName: 'blob'
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
  }
}

module storageAccountQueueNetworking '../../../../../shared/bicep/private-networking.bicep' = {
  name: 'storageAccountQueueNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateQueueDnsZoneName
    azServiceId: storageAccount.id
    privateEndpointName: queuePrivateEndpointName
    privateEndpointSubResourceName: 'queue'
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
  }
}


// ------------------
// OUTPUTS
// ------------------

@description('The external storage account name.')
output storageAccountName string = storageAccount.name
