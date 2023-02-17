targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('CIDR of the Spoke vnet i.e. 192.168.0.0/24')
param spokeVnetAddressSpace string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN  string 

@description('Whether to use a custom SSL certificate or not. If set to true, the certificate must be provided in the path configuration/appgwcert.pfx.')
param useCertificate bool = true

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
  vnetSpoke: '${naming.virtualNetwork.name}-spoke'
  acr: naming.containerRegistry.nameUnique
  keyvault: naming.keyVault.nameUnique
  userAssignedManagedIdentity: '${naming.userAssignedManagedIdentity.name}-aca'
  appInsights: naming.applicationInsights.name
  acaEnv: naming.containerAppsEnvironment.name
  appGw: naming.applicationGateway.name
}

var certificateKeyName = 'certificateName'

var subnetInfo = loadJsonContent('configuration/spoke-vnet-snet-config.jsonc')

var spokeVnetSubnets = [for item in subnetInfo.subnets: {
  name: item.name
  properties: {
    addressPrefix: item.addressPrefix
    privateEndpointNetworkPolicies: !contains(item, 'privateEndpointNetworkPolicies') ? 'Disabled' : (item.privateEndpointNetworkPolicies =~ 'Disabled' ? 'Disabled' : 'Enabled')
  }
}]

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

var sslCertPath = 'configuration/appgwcert.pfx'

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

module keyvaultModule '../../shared/bicep/modules/keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    hasPrivateEndpoint: true
    location: location
    name: resourceNames.keyvault
    tags: tags
    // TODO: check what is required
    accessPolicies: [
      {
        tenantId: acaUserAssignedManagedIdentity.outputs.tenantId
        objectId: acaUserAssignedManagedIdentity.outputs.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]     
          keys: [
            'get'
            'list'
          ] 
          certificates: [
            'get'
            'list'
          ]      
        }
      }
    ]
  }
}

resource sslCertSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (useCertificate) {
  name: '${resourceNames.keyvault}/${certificateKeyName}'
  dependsOn: [
    keyvaultModule
  ]
  properties: {
    value: loadFileAsBase64(sslCertPath)
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
    }
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
    name: 'pe-${keyvaultModule.outputs.keyvaultName}'
    location: location
    tags: tags
    privateDnsZonesId: keyvaultPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: keyvaultModule.outputs.keyvaultId
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

// give the managed Identity ACRPull on the ACR
module acaIdenityAcrPull '../../shared/bicep/modules/role-assignments/role-assignment.bicep' = {
  name: 'acaIdenityAcrPullDeployment'
  params: {
    resourceId: acr.outputs.acrResourceId
    principalId: acaUserAssignedManagedIdentity.outputs.principalId
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

//TODO: work in progress
// module sampleAca '../../shared/bicep/modules/aca-sample.bicep' = {
//   name: 'sampleAcaDeployment'
//   params: {
//     acrName: acr.outputs.acrName
//     containerAppName: 'casimplehello'
//     enableIngress: true
//     location: location
//     managedEnvironmentId: acaEnv.outputs.acaEnvResourceId
//     userAssignedIdentityId: acaUserAssignedManagedIdentity.outputs.id
//   }
// }

// module appGw 'application-gateway.bicep' = {
//   name: 'appGwDeployment'
//   params: {
//     appGatewayFQDN: appGatewayFQDN
//     appGatewaySubnetId: subnetAppGw.id 
//     certificateKeyName: (useCertificate)? certificateKeyName : '' 
//     keyvaultName: keyvaultModule.outputs.keyvaultName
//     location: location
//     name: resourceNames.appGw
//     primaryBackendEndFQDN: sampleAca.outputs.fqdn
//     keyVaultSecretId: (useCertificate) ? sslCertSecret.properties.secretUriWithVersion : ''
//   }
// }

output vnetSpokeName string = vnetSpoke.outputs.vnetName
