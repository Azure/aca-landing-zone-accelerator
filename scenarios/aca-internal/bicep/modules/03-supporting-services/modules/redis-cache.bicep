targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location

@description('The name of the redis cache to be created.')
param redisName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('The name of the private endpoint to be created for Redis Cache.')
param redisCachePrivateEndpointName string 

@description('The name of the deployed key vault')
param keyVaultName string

@description('Log Analytics Workspace Id')
param logAnalyticsWsId string


// ------------------
// VARIABLES
// ------------------

var privateDnsZoneNames = 'privatelink.redis.cache.windows.net'
var redisResourceName = 'redisCache'

var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]

var spokeVNetIdTokens = split(spokeVNetId, '/')
var spokeSubscriptionId = spokeVNetIdTokens[2]
var spokeResourceGroupName = spokeVNetIdTokens[4]
var spokeVNetName = spokeVNetIdTokens[8]

var spokeVNetLinks = [
  {
    vnetName: spokeVNetName
    vnetId: vnetSpoke.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]


// ------------------
// RESOURCES
// ------------------

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(spokeSubscriptionId, spokeResourceGroupName)  
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnetSpoke
  name: spokePrivateEndpointSubnetName
}

@description('Azure Redis Cache used for your workload.')
module redis '../../../../../shared/bicep/redis.bicep' = {
  name: 'redis-${uniqueString(resourceGroup().id)}'
  params: {
    name: redisName
    location: location
    tags: tags
    keyvaultName: keyVaultName
    enableNonSslPort: false
    skuName: 'Premium'
    diagnosticWorkspaceId : logAnalyticsWsId
    hasPrivateLink: true
  }
}

module redisPrivateNetworking '../../../../../shared/bicep/network/private-networking.bicep' = {
  name: 'redisPrivateNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServiceId: redis.outputs.resourceId
    azServicePrivateDnsZoneName: privateDnsZoneNames
    privateEndpointName: redisCachePrivateEndpointName
    privateEndpointSubResourceName: redisResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
    vnetHubResourceId: hubVNetId
  }
}

@description('The secret name to retrieve the connection string from KeyVault')
output redisCacheSecretKey string = redis.outputs.redisConnectionStringSecretName
