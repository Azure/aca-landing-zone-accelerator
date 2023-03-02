targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

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

var privateDnsZoneName = 'privatelink.documents.azure.com'

var cosmosDbAccountResourceName = 'Sql'

// ------------------
// RESOURCES
// ------------------

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

module cosmosDbNetworking '../../../../bicep/modules/private-networking.bicep' = {
  name: 'cosmosDbNetowrking-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    azServicePrivateDnsZoneName: privateDnsZoneName
    azServiceId: cosmosDbAccount.id
    privateEndpointName: cosmosDbPrivateEndpointName
    privateEndpointSubResourceName: cosmosDbAccountResourceName
    spokeSubscriptionId: subscription().subscriptionId
    spokeResourceGroupName: resourceGroup().name
    spokeVirtualNetworkName: spokeVNet.name
    spokeVirtualNetworkPrivateEndpointSubnetName: spokePrivateEndpointSubnet.name
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
