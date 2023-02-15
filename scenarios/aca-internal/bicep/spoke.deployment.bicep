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
}

var subnetInfo = loadJsonContent('configuration/spoke-vnet-snet-config.jsonc')

var spokeVnetSubnets = [for item in subnetInfo.subnets: {
  name: item.name
  properties: {
    addressPrefix: item.addressPrefix
    privateEndpointNetworkPolicies: !contains(item, 'privateEndpointNetworkPolicies') ? 'Disabled' : (item.privateEndpointNetworkPolicies =~ 'Disabled' ? 'Disabled' : 'Enabled')
  }
}]


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

// Deploy supporting services

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
