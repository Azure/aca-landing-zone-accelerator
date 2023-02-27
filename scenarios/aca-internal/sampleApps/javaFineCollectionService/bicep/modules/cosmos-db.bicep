targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string ='eslz-cosmosdb-${uniqueString(resourceGroup().id)}'
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string
@description('The name of Cosmos DB\'s private endpoint.')
param cosmosDbPrivateEndpointName string = 'pep-cosno-${uniqueString(resourceGroup().id)}'

// ------------------
//    VARIABLES
// ------------------

var privateDnsZoneName = 'privatelink.documents.azure.com'

var cosmosDbAccountResourceName = 'Sql'

// ------------------
// DEPLOYMENT TASKS
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
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
  }
}

resource cosmosDbDatabaseCollection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-05-15' = {
  name: cosmosDbCollectionName
  parent: cosmosDbDatabase
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
  name: 'cosmosDbNetworking'
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
