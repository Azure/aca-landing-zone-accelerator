targetScope = 'subscription'

// Parameters
param rgName string
param location string = deployment().location

param acrName string
param keyVaultName string
param acaUserAssignedIdentityName string

module rg 'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: location
  }
}

module acr 'modules/acr/acr.bicep' = {
  scope: resourceGroup(rg.name)
  name: acrName
  params: {
    location: location
    acrName: acrName
    acrSkuName: 'Premium'
  }
}

module keyvault 'modules/keyvault/keyvault.bicep' = {
  scope: resourceGroup(rg.name)
  name: keyVaultName
  params: {
    location: location
    keyVaultsku: 'Standard'
    name: keyVaultName
    tenantId: subscription().tenantId
  }
}

module acaIdentity 'modules/Identity/userassigned.bicep' = {
  scope: resourceGroup(rg.name)
  name: acaUserAssignedIdentityName
  params: {
    location: location
    identityName: acaUserAssignedIdentityName
  }
}

output acrName string = acr.name
output keyvaultName string = keyvault.name
output acaIdentityName string = acaIdentity.name
