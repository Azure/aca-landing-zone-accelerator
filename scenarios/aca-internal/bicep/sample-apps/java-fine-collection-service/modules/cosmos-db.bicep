targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string

@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string

@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string

@description('The name of Cosmos DB\'s private endpoint.')
param cosmosDbPrivateEndpointName string

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

var privateDnsZoneName = 'privatelink.documents.azure.com'
var cosmosDbAccountResourceName = 'Sql'

var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]

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

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: cosmosDbName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: 'Disabled'
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  name: cosmosDbDatabaseName
  parent: cosmosDbAccount
  tags: tags
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
  }
}

resource cosmosDbDatabaseCollection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-05-15' = {
  name: cosmosDbCollectionName
  parent: cosmosDbDatabase
  tags: tags
  properties: {
    resource: {
      id: cosmosDbCollectionName
      partitionKey: {
        paths: [
          '/partitionKey'
        ]
      }
    }
  }
}

module cosmosDbNetworking '../../../../../shared/bicep/private-networking.bicep' = {
  name: 'cosmosDbNetworking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneName
    azServiceId: cosmosDbAccount.id
    privateEndpointName: cosmosDbPrivateEndpointName
    privateEndpointSubResourceName: cosmosDbAccountResourceName
    virtualNetworkLinks: spokeVNetLinks
    subnetId: spokePrivateEndpointSubnet.id
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The name of Cosmos DB resource.')
output cosmosDbName string = cosmosDbAccount.name
@description('The name of Cosmos DB\'s database.')
output cosmosDbDatabaseName string = cosmosDbDatabase.name
@description('The name of Cosmos DB\'s collection.')
output cosmosDbCollectionName string = cosmosDbDatabaseCollection.name
