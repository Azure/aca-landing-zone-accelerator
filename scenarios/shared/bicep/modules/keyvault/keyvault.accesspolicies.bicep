param keyVaultName string

@description('Configuration of access policies, schema ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=json#microsoftkeyvaultvaultsaccesspolicies-object')
param accessPolicies array

resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: accessPolicies
  }
}
