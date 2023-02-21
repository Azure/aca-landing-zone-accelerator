targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('CIDR of the Spoke vnet i.e. 192.168.0.0/24')
param spokeVnetAddressSpace string

@description('CIDR of the subnet hosting Azure Container App Environment. For the current version (Feb 2023) you need at least /23 network')
param subnetInfraAddressSpace string

@description('CIDR of the subnet hosting the private endpoints of any desired servies (key vault, ACR, DBs etc')
param subnetPrivateEndpointAddressSpace string

@description('CIDR of the subnet hosting the application Gateway V2. needs to be big enough to accomdate scaling')
param subnetAppGwAddressSpace string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN  string 

@description('If true, then application Insights will be deployed to provide tracing facility for DAPR in azure container apps')
param acaDaprTracingWithAppInsights bool 

@description('Whether to use a custom SSL certificate or not. If set to true, the certificate must be provided in the path configuration/appgwcert.pfx.')
var  useCertificate = !empty(appGatewayFQDN) 

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
  vnetSpoke: '${naming.virtualNetwork.name}-spoke'
  acr: naming.containerRegistry.nameUnique
  keyvault: naming.keyVault.nameUnique
  userAssignedManagedIdentity: '${naming.userAssignedManagedIdentity.name}-aca'
  logAnalyticsWs: naming.logAnalyticsWorkspace.name
  appInsights: naming.applicationInsights.name
  acaEnv: naming.containerAppsEnvironment.name
  appGw: naming.applicationGateway.name
  nsgAppGw: 'nsg-${naming.applicationGateway.name}'
  nsgAca: 'nsg-aca'
  subnetInfra: 'snetInfra'
  subnetPrivateEndpoint: 'snetPE'
  subnetAppGw: 'snetAppGw'
}

var certificateKeyName = useCertificate ? replace(appGatewayFQDN, '.', '-') : 'NO-CERTIFICATE'

var subnets = [ 
  {
    name: resourceNames.subnetInfra
    properties: {
      addressPrefix: subnetInfraAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'  
      networkSecurityGroup: {
        id: nsgAca.outputs.nsgID
      } 
    } 
  }
  {
    name: resourceNames.subnetPrivateEndpoint
    properties: {
      addressPrefix: subnetPrivateEndpointAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'    
    }
  }
   {
    name: resourceNames.subnetAppGw
    properties: {
      addressPrefix: subnetAppGwAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'    
      networkSecurityGroup: {
        id: nsgAppGw.outputs.nsgID
      } 
    }
  }
]

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
    subnetsInfo: subnets
    tags: tags
    vnetAddressSpace:  spokeVnetAddressSpace
  }
}

module nsgAppGw '../../shared/bicep/modules/network/app-gw-nsg.bicep' = {
  name: 'appGwNsgDeployment'
  params: {
    location: location
    name: 'nsg-appGW'
    tags: tags
  }
}

module nsgAca '../../shared/bicep/modules/network/app-gw-nsg.bicep' = {
  name: 'acaEnvNsgDeployment'
  params: {
    location: location
    name: 'nsg-acaEnv'
    tags: tags
  }
}

resource subnetInfra 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${resourceNames.subnetInfra}'
}

resource subnetAppGw 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${resourceNames.subnetAppGw}'
}

resource subnetPrivateEndpoint 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${resourceNames.subnetPrivateEndpoint}'
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

module logAnalyticsWs '../../shared/bicep/modules/log-analytics-ws.bicep' = {
  name: 'logAnalyticsWsDeployment' 
  params: {
    location: location
    name: resourceNames.logAnalyticsWs
    tags: tags
  }
}

module appInsights '../../shared/bicep/modules/app-insights.bicep' = if (acaDaprTracingWithAppInsights) {
  name: 'appInsightsDeployment'
  params: {
    name: resourceNames.appInsights
    location: location
    tags: tags
    workspaceResourceId: logAnalyticsWs.outputs.logAnalyticsWsId
  }
}

module acaEnv '../../shared/bicep/modules/aca-environment.bicep' = {
  name: 'acaEnvironmentDeployment'
  params: {
    name: resourceNames.acaEnv
    location: location
    tags: tags
    logAnalyticsWsResourceId:  logAnalyticsWs.outputs.logAnalyticsWsId  
    subnetId: subnetInfra.id
    vnetEndpointInternal: true
    appInsightsInstrumentationKey: acaDaprTracingWithAppInsights ? appInsights.outputs.appInsInstrumentationKey : ''   
  }
}

// deploy Private DNSZones and Private Endpoints
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

//TODO: Consider flag for conditional deployment
module acaSampleHello '../../shared/bicep/modules/aca-hello-sample.bicep' = {
  name: 'acaSampleHelloDeployment'
  params: {
    location: location
    managedEnvironmentId: acaEnv.outputs.acaEnvResourceId 
    name: 'acaapphello' 
    userAssignedIdentityId: acaUserAssignedManagedIdentity.outputs.id  
  }
}

//TODO: work in progress 
module appGw 'application-gateway.bicep' = {
  name: 'appGwDeployment'
  params: {
    appGatewayFQDN: appGatewayFQDN
    appGatewaySubnetId: subnetAppGw.id 
    certificateKeyName: (useCertificate)? certificateKeyName : '' 
    keyvaultName: keyvaultModule.outputs.keyvaultName
    location: location
    name: resourceNames.appGw
    primaryBackendEndFQDN: acaSampleHello.outputs.fqdn
    keyVaultSecretId: (useCertificate) ? sslCertSecret.properties.secretUriWithVersion : ''
    logAnalyticsWsID: logAnalyticsWs.outputs.logAnalyticsWsId
  }
}


output vnetSpokeName string = vnetSpoke.outputs.vnetName
output sampleAppIngress string = acaSampleHello.outputs.fqdn
