param vnetName string
param subnetName string
param logAnalyticsWorkspaceName string
param acaIdentityName string

param databaseName string = 'eslz-cosmos-db-fines-${uniqueString(resourceGroup().id)}'
param accountName string = 'eslz-cosmos-fines-${uniqueString(resourceGroup().id)}'

//should be a var instead of a param. 
param location string = resourceGroup().location

resource vnetspoke 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetName}/${subnetName}'
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: acaIdentityName
  location: location
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}


resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: accountName
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
  name: databaseName
  parent: cosmosDbAccount
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource cosmosDbDatabaseCollection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-05-15' = {
  name: 'traffic-control-vehicle-state'
  parent: cosmosDbDatabase
  properties: {
    resource: {
      id: 'traffic-control-vehicle-state'
      partitionKey: {
        paths: [
          '/partitionKey'
        ]
      }
    }
  }
}


// TODO define recommended log category to export. Seems disabled in the portal.
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${cosmosDbAccount.name}-diagnosticLog'
  scope: cosmosDbAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}

//Create cosmosdb private dns zone and link it to spoke vnet
module cosmosDBDNSZone '../modules/privatednszones.bicep' = {
  name: 'cosmosDBPrivateDNSZoneDeployment'
  params: {
    privateDNSZoneName: 'privatelink.documents.azure.com'
    vnetID: vnetspoke.id
  }
}

//create private link and private endpoint for service bus in the services subnet
module cosmosDBPrivateLink '../modules/privateendpoint.bicep' = {
  name: 'cosmosDBPrivateEndpointDeployment'
  params: {
    privateEndpointName: 'cosmos-pvt-ep'
    region: location
    snetID: servicesSubnet.id
    pLinkServiceID: cosmosDbAccount.id
    serviceLinkGroupIds: ['Sql']
    privateDnsZonesId: cosmosDBDNSZone.outputs.privateDnsZonesId
  }
}

//assign cosmosdb account read/write access to aca user assigned identity
resource cosmosDBRole_assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  name: guid(subscription().id, '${acaIdentityName}', '00000000-0000-0000-0000-000000000002')
  parent: cosmosDbAccount
  properties: {
    principalId: acaIdentity.properties.principalId
    roleDefinitionId:  resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccount.name, '00000000-0000-0000-0000-000000000002')//DocumentDB Data Contributor
    scope:cosmosDbAccount.id
  }
  
}

output accountName string = cosmosDbAccount.name
output databaseName string = cosmosDbDatabase.name
output collectionName string = cosmosDbDatabaseCollection.name
