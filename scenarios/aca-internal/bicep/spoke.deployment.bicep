targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('CIDR of the Spoke vnet i.e. 192.168.0.0/24')
param spokeVnetAddressSpace string

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
  vnetSpoke: '${naming.virtualNetwork.name}-spoke'
  acr: naming.containerRegistry.nameUnique
  keyvault: naming.keyVault.nameUnique
  userAssignedManagedIdentity: '${naming.userAssignedManagedIdentity.name}-aca'
  appInsights: naming.applicationInsights.name
  acaEnv: naming.containerAppsEnvironment.name
}

var subnetInfo = loadJsonContent('configuration/spoke-vnet-snet-config.jsonc')

var spokeVnetSubnets = [for item in subnetInfo.subnets: {
  name: item.name
  properties: {
    addressPrefix: item.addressPrefix
    privateEndpointNetworkPolicies: !contains(item, 'privateEndpointNetworkPolicies') ? 'Disabled' : (item.privateEndpointNetworkPolicies =~ 'Disabled' ? 'Disabled' : 'Enabled')
  }
}]


//look https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-deployment#example-1
var privateDnsZoneNames = {
  acr: 'privatelink.azurecr.io'  
  keyvault: 'privatelink.vaultcore.azure.net'
}

var virtualNetworkLinks = [
  {
    vnetName: vnetSpoke.outputs.vnetName
    vnetId: vnetSpoke.outputs.vnetId
    registrationEnabled: false
  }
]

// Deploy Spoke network 
module vnetSpoke '../../shared/bicep/modules/network/vnet.bicep' = {
  name: 'vnetSpokeDeployment'
  params: {
    location: location
    name: resourceNames.vnetSpoke
    subnetsInfo: spokeVnetSubnets
    tags: tags
    vnetAddressSpace:  spokeVnetAddressSpace
  }
}

resource subnetInfra 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${subnetInfo.subnetInfra}'
}

resource subnetAppGw 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${subnetInfo.subnetAppGw}'
}

resource subnetPrivateEndpoint 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${subnetInfo.subnetPrivateEndpoint}'
}

// Deploy services
module acr '../../shared/bicep/modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    acrSku: 'Premium'
    name: resourceNames.acr
    location: location
    tags: tags
  }
}

module keyvault '../../shared/bicep/modules/keyvault/keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    hasPrivateEndpoint: true
    location: location
    name: resourceNames.keyvault
    tags: tags
  }
}

module acaUserAssignedManagedIdentity '../../shared/bicep/modules/managed-identity.bicep' = {
  name: 'acaManagedIdentityDeployment'
  params: {
    name: resourceNames.userAssignedManagedIdentity
    location: location
    tags: tags
  }
}

module appInsights '../../shared/bicep/modules/app-insights.bicep' = {
  name: 'appInsightsDeployment'
  params: {
    name: resourceNames.appInsights
    location: location
    tags: tags
  }
}

module acaEnv '../../shared/bicep/modules/aca-environment.bicep' = {
  name: 'acaEnvironmentDeployment'
  params: {
    name: resourceNames.acaEnv
    location: location
    tags: tags
    logAnalyticsWsResourceId:  appInsights.outputs.logAnalyticsWsId    
    subnetId: subnetInfra.id
    vnetEndpointInternal: true
    appInsightsInstrumentationKey: appInsights.outputs.appInsInstrumentationKey    
  }
}

// deploy Private DNSZones and Private Endpoints

// check https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-object#items
// module privateDnsZoneKeyvault '../../shared/bicep/modules/private-dns-zone.bicep' = {
//   name: 'privateDnsZoneAppConfigDeployment'
//   params: {
//     name: privateDnsZoneNames.keyvault
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

module acrPrivateDnsZone '../../shared/bicep/modules/private-dns-zone.bicep' = { 
  name: 'acrPrivateDnsZoneDeployment'
  params: {
    name: privateDnsZoneNames.acr
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module keyvaultPrivateDnsZone '../../shared/bicep/modules/private-dns-zone.bicep' = { 
  name: 'keyvaultPrivateDnsZoneDeployment'
  params: {
    name: privateDnsZoneNames.keyvault
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module acaEnvPrivateDnsZone  '../../shared/bicep/modules/private-dns-zone.bicep' = {
  name: 'acaEnvPrivateDnsZoneDeployment'
  params: {
    name: acaEnv.outputs.acaEnvDefaultDomain
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
    aRecords: [
      {
        name: '*'
        ipv4Address: acaEnv.outputs.acaEnvLoadBalancerIP
      }
    ]
  }
}

module peKeyvault '../../shared/bicep/modules/private-endpoint.bicep' = {
  name: 'peKeyvaultDeployment'
  params: {
    name: 'pe-${keyvault.outputs.keyvaultName}'
    location: location
    tags: tags
    privateDnsZonesId: keyvaultPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: keyvault.outputs.keyvaultId
    snetId: subnetPrivateEndpoint.id
    subresource: 'vault'
  }
}

module peAcr '../../shared/bicep/modules/private-endpoint.bicep' = {
  name: 'peAcrDeployment'
  params: {
    name: 'pe-${acr.outputs.acrName}'
    location: location
    tags: tags
    privateDnsZonesId: acrPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: acr.outputs.acrResourceId
    snetId: subnetPrivateEndpoint.id
    subresource: 'registry'
  }
}
