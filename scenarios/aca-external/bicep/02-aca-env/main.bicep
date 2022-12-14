targetScope = 'subscription'

param rgName string
param acaLaWorkspaceName string
param acaEnvName string
param location string = deployment().location

param acrName string
param keyVaultName string
param acaIdentityName string

// Check if assets already exist

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(rg.name)
  name: acaIdentityName
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  scope: resourceGroup(rg.name)
  name: keyVaultName
}

// Create assets

module rg 'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: location
  }
}

module logAnalyticsWorkspace 'modules/laworkspace/la.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'logAnalyticsWorkspace'
  params: {
    location: location
    workspaceName: acaLaWorkspaceName
  }
}

module containerAppEnvironment 'modules/aca-env/container-app-env.bicep' = {
  scope: resourceGroup(rg.name)
   name: 'containerAppEnvironment'
    params: {
        name: acaEnvName
        location: location
        lawClientId: logAnalyticsWorkspace.outputs.clientId
        lawClientSecret: logAnalyticsWorkspace.outputs.clientSecret
    }
    dependsOn: [
      logAnalyticsWorkspace
    ]
}

module setAcaAccessToAcr 'modules/Identity/acrrole.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'setAcaAccessToAcr'
  params: {
    principalId: acaIdentity.properties.principalId
    roleGuid: '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
    acrName: acrName
  }
}

module keyvaultAccessPolicy 'modules/keyvault/keyvault.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'setAcaKeyVaultAddonAccessPolicy'
  params: {
    keyvaultManagedIdentityObjectId: acaIdentity.properties.principalId
    vaultName: keyVaultName
    acaUserAccessPrincipalId: acaIdentity.properties.principalId
  }
  dependsOn: [
    keyVault
  ]
}
