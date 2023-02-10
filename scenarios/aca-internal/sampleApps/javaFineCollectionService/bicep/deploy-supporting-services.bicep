@description('The region (location) in which the resource will be deployed. Default: resource group location.')
param location string = resourceGroup().location

@description('The name of the spoke VNET.')
param spokeVNetName string
@description('The name of the subnet for supporting services of the spoke')
param servicesSubnetName string = 'servicespe'

@description('The name of the service bus namespace.')
param serviceBusName string = 'eslz-sb-${uniqueString(resourceGroup().id)}'
@description('The name of the service bus topic.')
param serviceBusTopicName string
@description('The name of the service bus topic\'s authorization rule.')
param serviceBusTopicAuthorizationRuleName string
@description('The name of service bus\' private endpoint.')
param serviceBusPrivateEndpointName string
@description('The name of service bus\' private dns zone.')
param serviceBusPrivateDNSZoneName string
@description('The name of service bus\' private dns zone link to spoke VNET.')
param serviceBusPrivateDNSLinkSpokeName string = 'sb-pvt-dns-link-spoke'

@description('The name of Cosmos DB resource.')
param cosmosDbName string ='eslz-cosmosdb-${uniqueString(resourceGroup().id)}'
@description('The name of Cosmos DB\'s database.')
param cosmosDbDatabaseName string
@description('The name of Cosmos DB\'s collection.')
param cosmosDbCollectionName string
@description('The name of Cosmos DB\'s private endpoint.')
param cosmosDbPrivateEndpointName string
@description('The name of Cosmos DB\'s private dns zone.')
param cosmosDbPrivateDNSZoneName string
@description('The name of Cosmos DB\'s private dns zone link to spoke VNET.')
param cosmosDbPrivateDNSLinkSpokeName string

resource spokeVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVNetName
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${spokeVNet.name}/${servicesSubnetName}'
}

/*
 * Azure Service Bus
 */

// TODO check version Public network only available in the preview
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }

  properties: {
    disableLocalAuth: false // TODO should not allow local auth with SAS token
    publicNetworkAccess: 'Disabled'
  }
}

resource serviceBusTestTopic 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' = {
  name: serviceBusTopicName
  parent: serviceBusNamespace
}

// TODO remove this when managed identity is used
resource serviceBusTestTopicAuthRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' = {
  name: serviceBusTopicAuthorizationRuleName
  parent: serviceBusTestTopic
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

module serviceBusPrivateEndpoint '../../../bicep/modules/vnet/privateendpoint.bicep' = {
  name: serviceBusPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'namespace'
    ]
    privateEndpointName: serviceBusPrivateEndpointName
    privatelinkConnName: '${serviceBusPrivateEndpointName}-conn'
    resourceId: serviceBusNamespace.id
    subnetid: servicesSubnet.id
  }
}

module serviceBusPrivateDNSZone '../../../bicep/modules/vnet/privatednszone.bicep' = {
  name: serviceBusPrivateDNSZoneName
  params: {
     privateDNSZoneName: 'privatelink.servicebus.windows.net'
  }
}

module serviceBusPrivateDNSZoneLinkSpoke '../../../bicep/modules/vnet/privatednslink.bicep' = {
  name: serviceBusPrivateDNSLinkSpokeName
  params: {
    privateDnsZoneName: serviceBusPrivateDNSZone.outputs.privateDNSZoneName
    vnetId: spokeVNet.id
    linkname: 'spoke'
  }
}

module serviceBusPrivateEndpointDnsSetting '../../../bicep/modules/vnet/privatedns.bicep' = {
  name: 'sb-pvtep-dns'
  params: {
    privateDNSZoneId: serviceBusPrivateDNSZone.outputs.privateDNSZoneId
    privateEndpointName: serviceBusPrivateEndpoint.outputs.privateEndpointName
  }
}


/*
 * Azure Cosmos DB 
 */

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

module cosmosDbPrivateEndpoint '../../../bicep/modules/vnet/privateendpoint.bicep' = {
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

module cosmosDbPrivateDNSZone '../../../bicep/modules/vnet/privatednszone.bicep' = {
  name: cosmosDbPrivateDNSZoneName
  params: {
     privateDNSZoneName: 'privatelink.documents.azure.com'
  }
}

module cosmosDbPrivateDNSZoneLinkSpoke '../../../bicep/modules/vnet/privatednslink.bicep' = {
  name: cosmosDbPrivateDNSLinkSpokeName
  params: {
    privateDnsZoneName: cosmosDbPrivateDNSZone.outputs.privateDNSZoneName
    vnetId: spokeVNet.id
    linkname: 'spoke'
  }
}

module cosmosDbPrivateEndpointDnsSetting '../../../bicep/modules/vnet/privatedns.bicep' = {
  name: 'cdb-pvtep-dns'
  params: {
    privateDNSZoneId: cosmosDbPrivateDNSZone.outputs.privateDNSZoneId
    privateEndpointName: cosmosDbPrivateEndpoint.outputs.privateEndpointName
  }
}
