targetScope = 'subscription'
//param envname string = 'srtestacabic'
param lz_prefix string = 'acatest18'
param rgName string
param acalaWorkspaceName string
param vnetName string
param subnetName string
param acaIdentityName string
param location string = deployment().location

param acrName string //User to provide each time
param keyvaultName string //user to provide each time

module rg 'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: location
  }
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(rg.name)
  name: acaIdentityName
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
  name: '${vnetName}/${subnetName}'
}


module containerAppEnvironment 'modules/aca/container-app-env.bicep' = {
  scope: resourceGroup(rg.name)
   name: 'ACA-env-Deploy'
    params: {
        name: envname
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




