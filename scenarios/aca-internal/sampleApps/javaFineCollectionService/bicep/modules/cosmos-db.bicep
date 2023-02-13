@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet for supporting services of the spoke')
param servicesSubnetName string

@description('The name of Cosmos DB resource.')
param cosmosDbName string ='eslz-cosmosdb-${uniqueString(resourceGroup().id)}'
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string
@description('The name of Cosmos DB\'s private endpoint.')
param cosmosDbPrivateEndpointName string = 'cdb-pvt-ep'
@description('The name of Cosmos DB\'s private dns zone.')
param cosmosDbPrivateDNSZoneName string = 'cdb-pvt-dns'
@description('The name of Cosmos DB\'s private dns zone link to spoke VNET.')
param cosmosDbPrivateDNSLinkSpokeName string = 'cdb-pvt-dns-link-spoke'

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${spokeVNet.name}/${servicesSubnetName}'
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

module cosmosDbPrivateEndpoint '../../../../bicep/modules/vnet/privateendpoint.bicep' = {
  name: cosmosDbPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'Sql'
    ]
    privateEndpointName: cosmosDbPrivateEndpointName
    privatelinkConnName: '${cosmosDbPrivateEndpointName}-conn'
    resourceId: cosmosDbAccount.id
    subnetid: servicesSubnet.id
  }
}

module cosmosDbPrivateDNSZone '../../../../bicep/modules/vnet/privatednszone.bicep' = {
  name: cosmosDbPrivateDNSZoneName
  params: {
     privateDNSZoneName: 'privatelink.documents.azure.com'
  }
}

module cosmosDbPrivateDNSZoneLinkSpoke '../../../../bicep/modules/vnet/privatednslink.bicep' = {
  name: cosmosDbPrivateDNSLinkSpokeName
  params: {
    privateDnsZoneName: cosmosDbPrivateDNSZone.outputs.privateDNSZoneName
    vnetId: spokeVNet.id
    linkname: 'spoke'
  }
}

module cosmosDbPrivateEndpointDnsSetting '../../../../bicep/modules/vnet/privatedns.bicep' = {
  name: 'cdb-pvtep-dns'
  params: {
    privateDNSZoneId: cosmosDbPrivateDNSZone.outputs.privateDNSZoneId
    privateEndpointName: cosmosDbPrivateEndpoint.outputs.privateEndpointName
  }
}

@description('The name of Cosmos DB resource.')
output cosmosDbName string = cosmosDbAccount.name
@description('The name of Cosmos DB\'s database.')
output cosmosDbDatabaseName string = cosmosDbDatabase.name
@description('The name of Cosmos DB\'s collection.')
output cosmosDbCollectionName string = cosmosDbDatabaseCollection.name
