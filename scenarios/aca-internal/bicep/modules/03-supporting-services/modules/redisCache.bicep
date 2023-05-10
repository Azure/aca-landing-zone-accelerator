targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Reference to the naming monudle deployed')
param naming object

@description('The name of the deployed key vault')
param keyVaultName string

@description('Log Analytics Workspace Id')
param logAnalyticsWsId string

@description('The vnet id where the resources will be deployed')
param redisVNetId string

@description('The vnet subnet name where the resources will be deployed')
param redisSubnetName string

@description('The name of the private endpoint to be created for Redis Cache.')
param redisCachePrivateEndpointName string = 'pe-${naming.outputs.resourcesNames.redisCache}'

var privateDnsZoneNames = 'privatelink.redis.cache.windows.net'
var vNetIdTokens = split(redisVNetId, '/')
var vNetName = vNetIdTokens[8]

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vNetName
}

resource redisSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnet
  name: redisSubnetName
}

@description('Azure Redis Cache used for your workload.')
module redis '../../../../../shared/bicep/redis.bicep' = {
  name: 'redis-${uniqueString(resourceGroup().id)}'
  params: {
    name: naming.outputs.resourcesNames.redisCache
    location: location
    tags: tags
    keyvaultName: keyVaultName
    enableNonSslPort: false
    skuName: 'Premium'
    diagnosticWorkspaceId : logAnalyticsWsId
    hasPrivateLink: true
  }
}

module redisPrivateNetworking '../../../../../shared/bicep/private-networking.bicep' = {
  name: 'redisPrivateNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServiceId: redis.outputs.resourceId
    azServicePrivateDnsZoneName: privateDnsZoneNames
    privateEndpointName: redisCachePrivateEndpointName
    privateEndpointSubResourceName: 'redisCache'
    virtualNetworkLinks: [
      vnet.id
    ]
    subnetId: redisSubnet.id
  }
}

@description('The secret name to retrieve the connection string from KeyVault')
output redisCacheSecretKey string = redis.outputs.redisConnectionStringSecretName
