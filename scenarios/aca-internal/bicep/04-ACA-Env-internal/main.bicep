targetScope = 'subscription'
param containerEnvname string = 'srtestacabi'
param lz_prefix string = 'acatest18'
param spokeRgName string
param acalaWorkspaceName string
param spokevnetName string
param subnetName string
param acaIdentityName string
param location string = deployment().location
param vnetHubName string
param vnetHUBRGName string
param containerAppName string

param acrName string //User to provide each time
param keyvaultName string //user to provide each time

module rg 'modules/resource-group/rg.bicep' = {
  name: spokeRgName
  params: {
    rgName: spokeRgName
    location: location
  }
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(rg.name)
  name: acaIdentityName
}

resource vnetspoke 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  scope: resourceGroup(rg.name)
  name: spokevnetName
}

resource vnethub 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  scope: resourceGroup(vnetHUBRGName)
  name: vnetHubName
}

module acalaworkspace 'modules/laworkspace/la.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'acalaworkspace'
  params: {
    location: location
    workspaceName: acalaWorkspaceName
  }
}

resource acaSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  scope: resourceGroup(rg.name)
  name: '${spokevnetName}/${subnetName}'
}


module containerAppEnvironment 'modules/aca/container-app-env.bicep' = {
  scope: resourceGroup(rg.name)
   name: 'ACA-env-Deploy'
    params: {
        name: containerEnvname
        location: location
        lawClientId: acalaworkspace.outputs.clientId
        lawClientSecret: acalaworkspace.outputs.clientSecret
        infrasubnet: acaSubnet.id
       // runtimesubnet: spokenetwork.outputs.infrasubnet
    }
    dependsOn: [
      acalaworkspace
    ]
}


module acracaaccess 'modules/Identity/acrrole.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'acracaaccess'
  params: {
    principalId: acaIdentity.properties.principalId
    roleGuid: '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
    acrName: acrName
  }
}



module keyvaultAccessPolicy 'modules/keyvault/keyvault.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'acakeyvaultaddonaccesspolicy'
  params: {
    keyvaultManagedIdentityObjectId: acaIdentity.properties.principalId
    vaultName: keyvaultName
    acauseraccessprincipalId: acaIdentity.properties.principalId
  }
}

module acadnszone '../02-Network-LZ/modules/vnet/privatednszone.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privatednsACAZone'
  params: {
    privateDNSZoneName: containerAppEnvironment.outputs.envfqdn
  }
  
}

module privateDNSLinkACAHub '../02-Network-LZ/modules/vnet/privatednslink.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privateDNSLinkACAHub'
  params: {
    privateDnsZoneName: containerAppEnvironment.outputs.envfqdn
    vnetId: vnethub.id
    linkname: 'ACA-hub'
  }
  dependsOn: [
    acadnszone
  ]
}

module privateDNSLinkACAspoke '../02-Network-LZ/modules/vnet/privatednslink.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privateDNSLinkACAspoke'
  params: {
    privateDnsZoneName: containerAppEnvironment.outputs.envfqdn
    vnetId: vnetspoke.id
    linkname: 'ACA-spoke'
  }
  dependsOn: [
    acadnszone
  ]
}

module record './modules/Arecord.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'recordNameArecord'
  params: {
    envstaticip: containerAppEnvironment.outputs.envip
    recordName: containerAppName
    privateDNSZoneName: containerAppEnvironment.outputs.envfqdn
  }
  dependsOn: [
    acadnszone
  ]
}






