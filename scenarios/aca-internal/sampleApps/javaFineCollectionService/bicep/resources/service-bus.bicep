param vnetName string
param subnetName string
param logAnalyticsWorkspaceName string
param acaIdentityName string


//should be a var instead of a param. 
param location string = resourceGroup().location

resource vnetspoke 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetName}/${subnetName}'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: acaIdentityName
  location: location
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'eslz-sb-${uniqueString(resourceGroup().id)}'
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

// TODO define recommended log category to export
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${serviceBusNamespace.name}-diagnosticLog'
  scope: serviceBusNamespace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'OperationalLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}

resource serviceBusTestTopic 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' = {
  name: 'test'
  parent: serviceBusNamespace
}


//Create servicebus private dns zone and link it to spoke vnet
module sbDNSZone '../modules/privatednszones.bicep' = {
  name: 'serviceBusPrivateDNSZoneDeployment'
  params: {
    privateDNSZoneName: 'privatelink.servicebus.windows.net'
    vnetID: vnetspoke.id
  }
}

//create private link and private endpoint for service bus in the services subnet
module sbPrivateLink '../modules/privateendpoint.bicep' = {
  name: 'serviceBusPrivateEndpointDeployment'
  params: {
    privateEndpointName: 'sb-pvt-ep'
    region: location
    snetID: servicesSubnet.id
    pLinkServiceID: serviceBusNamespace.id
    serviceLinkGroupIds: ['namespace']
    privateDnsZonesId: sbDNSZone.outputs.privateDnsZonesId
  }
}


//enable send/receive to aca user assigned identity
resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, '${acaIdentityName}', '090c5cfd-751d-490a-894a-3ce6f1109419')
  properties: {
    principalId: acaIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')//Azure Service Bus Data Owner
  }
  
  scope: serviceBusNamespace
}

output name string = serviceBusNamespace.name
