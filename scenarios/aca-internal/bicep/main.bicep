targetScope = 'subscription'
@description('Name of the Resource group in which the hub resources will be deployed.')
param hubRgName string
@description('Name of the Hub Virtual Network to be created.')
param vnetHubName string
@description('CIDR of the Hub Virtual Network.')
param hubVnetAddressPrefix array
@description('Hub subnets to created.')
param hubSubnets array

@description('Azure location to which the resources are to be deployed')
param location string = deployment().location
//param deployFW bool
@description('Select this parameter to be true if you need bastion to be deployed.')
param deployBastion bool
@description('Select OS of the jumpbox VM.It can be linux or windows ostype for the jumpbox')
@allowed([
  'linux'
  'windows'
])
param jumpboxOsType string = 'linux'
@description('Name of the subnet in which your jumpbox VM will be deployed.')
param vmSubnetName string
@description('Address Prefix of the bastion subnet in which your bastion will be deployed.')
param bastionSubnetAddressPrefix string
param publicKeyData string
@description('Valid SKU indicator for the VM')
param vmSize string
@description('The user name to be used as the Administrator for all VMs created by this deployment')
param adminUsername string
@description('The password for the Administrator user for all VMs created by this deployment')
param adminPassword string

@description('Name of the Resource group in which the spoke resources will be deployed.')
param spokeRgName string
@description('Name of the Spoke Virtual Network to be created.')
param vnetSpokeName string
@description('CIDR of the Spoke Virtual Network.')
param spokeVnetAddressPrefix array
@description('Soke subnets to created.')
param spokeSubnets array
@description('Name of the Network Security group for the subnet in which container app environment will be injected.')
param nsgAcaName string

@description('Select this parameter to be true if you need appinsights to be deployed.')
param deployApplicationInsightsDaprInstrumentation bool
@description('Name of the subnet in which your container apps will be injected.')
param acaSubnetName string
@description('Name of the subnet in which application gateway will be injected.')
var gwSubnetName = 'appGatewaySubnetName'

@description('Name of the Private Endpoint for your KeyVault.')
param keyVaultPrivateEndpointName string
@description('Name of the Private Endpoint for your container registry.')
param acrPrivateEndpointName string

param privateDnsZoneAcrName string
param privateDnsZoneKvName string
param acrName string = 'eslzacr${uniqueString('acrvws',utcNow('u'))}'
param keyvaultName string = 'eslz-kv-${uniqueString('acrvws',utcNow('u'))}'
param appInsightsName string


//var acrName = 'eslzacr${uniqueString(spokergName, deployment().name)}'
//var keyvaultName = 'eslz-kv-${uniqueString(spokergName, deployment().name)}'



param containerEnvName string

param acaLaWorkspaceName string
param peSubnetName string
param acaIdentityName string

param containerAppName string



// Deploy Hub Network

//Create Hub Resource Group
module hubrg './modules/resource-group/rg.bicep' = {
  name: hubRgName
  params: {
    rgName: hubRgName
    location: location
  }
}

//Create Hub Vnet
module vnethub './modules/vnet/vnet.bicep' = {
  scope: resourceGroup(hubrg.name)
  name: vnetHubName
  params: {
    location: location
    vnetAddressSpace: {
        addressPrefixes: hubVnetAddressPrefix
    }
    vnetName: vnetHubName
    subnets: hubSubnets
  }
  dependsOn: [
    hubrg
  ]
}

// Create public IP for bastion. It will be created only if you want to deploy bastion.
module publicipbastion './modules/vm/public-ip.bicep' = if (deployBastion) {
  scope: resourceGroup(hubrg.name)
  name: 'publicipbastion'
  params: {
    location: location
    publicipName: 'bastion-pip'
    deploybastion: deployBastion
    publicipproperties: {
      publicIPAllocationMethod: 'Static'
    }
    publicipsku: {
      name: 'Standard'
      tier: 'Regional'
    }
  }
}


resource subnetbastion 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = if (deployBastion) {
  scope: resourceGroup(hubrg.name)
  name: '${vnetHubName}/AzureBastionSubnet'
}

//Create Bastion Resource
module bastion 'modules/vm/bastion.bicep' = if (deployBastion) {
  scope: resourceGroup(hubrg.name)
  name: 'bastion'
  params: {
    location: location
    bastionpipId: publicipbastion.outputs.publicipId
    subnetId: subnetbastion.id
    deploybastion: deployBastion
    bastionAddressPrefix: bastionSubnetAddressPrefix
    vnetHubName: vnetHubName
  }
  dependsOn: [
    hubrg
    vnethub
    jumpbox
  ]
}




// Deploy Virtual Machine in Hub (linux or Windows)


module jumpbox 'modules/vm/virtual-machine.bicep' = if (jumpboxOsType == 'linux') {
  scope: resourceGroup(hubrg.name)
  name: 'jumpbox'
  params: {
    location: location
    publicKey: publicKeyData
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    osType: jumpboxOsType
    vnetHubName: vnetHubName
    VMSubnetName: vmSubnetName
  }
  dependsOn: [
    hubrg
    vnethub
  ]
}

module vm_jumpboxwinvm 'modules/vm/create-vm-windows.bicep' = if (jumpboxOsType == 'windows') {
  name: 'vm-jumpbox'
  scope: resourceGroup(hubrg.name)
  params: {
    location: location
    username: adminUsername
    password: adminPassword
    CICDAgentType: 'none'
    vmName: 'jumpbox'
    osType: jumpboxOsType
    vnetHubName: vnetHubName
    VMSubnetName: vmSubnetName
  }
  dependsOn: [
    hubrg
    vnethub
    bastion
  ]
}





// Deploy Spoke Network


module spokerg 'modules/resource-group/rg.bicep' = {
  name: spokeRgName
  params: {
    rgName: spokeRgName
    location: location
  }
}

module vnetspoke 'modules/vnet/vnet.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: vnetSpokeName
  params: {
    location: location
    vnetAddressSpace: {
      addressPrefixes: spokeVnetAddressPrefix
    }
    vnetName: vnetSpokeName
    subnets: spokeSubnets
   // dhcpOptions: dhcpOptions
  }
  dependsOn: [
    spokerg
  ]
}

module nsgacasubnet 'modules/vnet/aca-nsg.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: nsgAcaName
  params: {
    location: location
    nsgName: nsgAcaName
  }
}

module nsggwsubnet 'modules/vnet/app-gw-nsg.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'nsggwsubnet'
  params: {
    location: location
  }
}


module vnetpeeringhub 'modules/vnet/vnet-peering.bicep' = {
  scope: resourceGroup(hubrg.name)
  name: 'vnetpeeringhub'
  params: {
    peeringName: 'HUB-to-Spoke'
    vnetName: vnethub.name
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnetspoke.outputs.vnetId
      }
    }
  }
  dependsOn: [
    vnethub
    vnetspoke
  ]
}

module vnetpeeringspoke 'modules/vnet/vnet-peering.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'vnetpeeringspoke'
  params: {
    peeringName: 'Spoke-to-HUB'
    vnetName: vnetspoke.outputs.vnetName
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnethub.outputs.vnetId
      }
    }
  }
  dependsOn: [
    vnethub
    vnetspoke
  ]
}



 module privatednsACRZone 'modules/vnet/private-dns-zone.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privatednsACRZone'
  params: {
    privateDNSZoneName: 'privatelink.azurecr.io'
  }
}

module privateDNSLinkACR 'modules/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACR'
  params: {
    privateDnsZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetId: vnethub.outputs.vnetId
    linkname: 'hub'
  }
}

module privateDNSLinkACRspoke 'modules/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACRspoke'
  params: {
    privateDnsZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'spoke'
  }
 
}

module privatednsVaultZone 'modules/vnet/private-dns-zone.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privatednsVaultZone'
  params: {
    privateDNSZoneName: 'privatelink.vaultcore.azure.net'
  }
}

module privateDNSLinkVault 'modules/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkVault'
  params: {
    privateDnsZoneName: privatednsVaultZone.outputs.privateDNSZoneName
    vnetId: vnethub.outputs.vnetId
    linkname: 'hub'
  }
}

module privateDNSLinkVaultspoke 'modules/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkVaultspoke'
  params: {
    privateDnsZoneName: privatednsVaultZone.outputs.privateDNSZoneName
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'spoke'
  }

}



module updateACANSG 'modules/vnet/subnet.bicep' = {
scope: resourceGroup(spokerg.name)
  name: 'updateNSG'
  params: {
    subnetName: acaSubnetName
    vnetName: vnetSpokeName
    properties: {
     addressPrefix: spokeSubnets[0].properties.addressPrefix
      networkSecurityGroup: {
        id: nsgacasubnet.outputs.nsgID
      }
    }
  }
  dependsOn: [  
    vnetspoke
    vnetpeeringhub
    vnetpeeringspoke
  ]
}



module updateGWNSG 'modules/vnet/subnet.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'updateGWNSG'
  params: {
    subnetName: gwSubnetName
    vnetName: vnetSpokeName
    properties: {
      addressPrefix: spokeSubnets[2].properties.addressPrefix
      networkSecurityGroup: {
        id: nsggwsubnet.outputs.nsgID
      }
    }
  }
  dependsOn: [
    updateACANSG
    vnetspoke 
    vnetpeeringhub
    vnetpeeringspoke 
  ]
}



// Deploy supporting services




module acr 'modules/acr/acr.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: acrName
  params: {
    location: location
    acrName: acrName
    acrSkuName: 'Premium'
  }
}

module keyvault 'modules/keyvault/keyvault.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: keyvaultName
  params: {
    location: location
    keyVaultsku: 'Standard'
    name: keyvaultName
    tenantId: subscription().tenantId
  }
}


resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  scope: resourceGroup(spokerg.name)
  name: '${vnetSpokeName}/${peSubnetName}'
}

module privateEndpointKeyVault 'modules/vnet/private-endpoint.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: keyVaultPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'Vault'
    ]
    privateEndpointName: keyVaultPrivateEndpointName
    privatelinkConnName: '${keyVaultPrivateEndpointName}-conn'
    resourceId: keyvault.outputs.keyvaultId
    subnetid: servicesSubnet.id
  }
}

module privateEndpointAcr 'modules/vnet/private-endpoint.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: acrPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'registry'
    ]
    privateEndpointName: acrPrivateEndpointName
    privatelinkConnName: '${acrPrivateEndpointName}-conn'
    resourceId: acr.outputs.acrid
    subnetid: servicesSubnet.id
  }
}



resource privateDNSZoneACR 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(spokerg.name)
  name: privateDnsZoneAcrName
}

module privateEndpointACRDNSSetting 'modules/vnet/private-dns.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acr-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneACR.id
    privateEndpointName: privateEndpointAcr.name
  }
}

resource privateDNSZoneKV 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(spokerg.name)
  name: privateDnsZoneKvName
}

module privateEndpointKVDNSSetting 'modules/vnet/private-dns.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'kv-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneKV.id
    privateEndpointName: privateEndpointKeyVault.name
  }
}



module acaIdentity 'modules/identity/user-assigned.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acaIdentity'
  params: {
    location: location
    identityName: acaIdentityName
  }
}

output acrName string = acr.name
output keyvaultName string = keyvault.name



//Deploy Container App Environment




module acalaworkspace 'modules/laworkspace/la.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acalaworkspace'
  params: {
    location: location
    workspaceName: acaLaWorkspaceName
  }
}

module acaApplicationInsights 'modules/app-insights/ai.bicep' = if (deployApplicationInsightsDaprInstrumentation) {
  scope: resourceGroup(spokerg.name)
  name: 'acaAppInsights'
  params: {
    name: appInsightsName
    location: location
    laworkspaceId: acalaworkspace.outputs.laworkspaceId
  }
}


module containerAppEnvironment 'modules/aca/container-app-env.bicep' = {
  scope: resourceGroup(spokerg.name)
   name: 'ACA-env-Deploy'
    params: {
        name: containerEnvName
        location: location
        infrasubnet: '${vnetspoke.outputs.vnetId}/subnets/${acaSubnetName}'
        workspaceName: acaLaWorkspaceName
        applicationInsightsName: (deployApplicationInsightsDaprInstrumentation ?  acaApplicationInsights.outputs.appInsightsName : '')
       // runtimesubnet: spokenetwork.outputs.infrasubnet
    }
    dependsOn: [
      acalaworkspace
    ]
}


module acracaaccess 'modules/identity/acr-role.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acracaaccess'
  params: {
    principalId: acaIdentity.outputs.principalId
    roleGuid: '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
    acrName: acrName
  }
  dependsOn: [
    acaIdentity
    acr
    containerAppEnvironment
  ]
}



module keyvaultAccessPolicy 'modules/keyvault/keyvault-access.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acakeyvaultaddonaccesspolicy'
  params: {
    keyvaultManagedIdentityObjectId: acaIdentity.outputs.principalId
    vaultName: keyvaultName
    acauseraccessprincipalId: acaIdentity.outputs.principalId
  }
}

module acadnszone 'modules/vnet/private-dns-zone.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privatednsACAZone'
  params: {
    privateDNSZoneName: containerAppEnvironment.outputs.envfqdn
  }
  
}

module privateDNSLinkACAHub 'modules/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACAHub'
  params: {
    privateDnsZoneName: containerAppEnvironment.outputs.envfqdn
    vnetId: vnethub.outputs.vnetId
    linkname: 'ACA-hub'
  }
  dependsOn: [
    acadnszone
  ]
}

module privateDNSLinkACAspoke 'modules/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACAspoke'
  params: {
    privateDnsZoneName: containerAppEnvironment.outputs.envfqdn
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'ACA-spoke'
  }
  dependsOn: [
    acadnszone
  ]
}

module record 'modules/vnet/a-record.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'recordNameArecord'
  params: {
    envstaticip: containerAppEnvironment.outputs.envip
    recordName: containerAppName
    privateDNSZoneName: containerAppEnvironment.outputs.envfqdn
  }
  dependsOn: [
    acadnszone
    containerAppEnvironment
  ]
}





