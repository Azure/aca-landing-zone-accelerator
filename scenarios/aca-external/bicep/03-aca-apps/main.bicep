targetScope = 'subscription'

param rgName string
param location string = deployment().location

param acrName string
param keyVaultName string
param acaIdentityName string
param acaEnvName string

param appName string
param containerName string
param containerImage string
param resourceCpu string
param resourceMemory string
param useExternalIngress bool
param containerPort int
param envVars array = []

// Check if assets already exist

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  scope: resourceGroup(rg.name)
  name: acrName
}
  
resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(rg.name)
  name: acaIdentityName
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  scope: resourceGroup(rg.name)
  name: keyVaultName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  scope: resourceGroup(rg.name)
  name: acaEnvName
}

// Create assets

module rg 'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: location
  }
}

module containerApp 'modules/aca-app/aca-app.bicep' = {
  scope: resourceGroup(rg.name)
   name: 'containerApp'
    params: {
        name: appName
        location: location
        containerAppEnvironmentId: containerAppEnvironment.id
        containerImage: containerImage
        containerName: containerName
        containerPort: containerPort
        envVars: envVars
        useExternalIngress: useExternalIngress
        registryIdentityId: acaIdentity.id
        registryServer: acr.properties.loginServer
        resourceCpu: resourceCpu
        resourceMemory: resourceMemory
    }
    dependsOn: [
      containerAppEnvironment
      acaIdentity
      acr
      keyVault
    ]
}
