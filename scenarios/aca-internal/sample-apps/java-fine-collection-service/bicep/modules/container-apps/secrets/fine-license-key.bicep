targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the Key Vault.')
param keyVaultName string

@description('The name of the secret containing the license key value for Fine Collection Service.')
param fineLicenseKeySecretName string

@secure()
@description('The license key for Fine Collection Service.')
param fineLicenseKeySecretValue string

@description('The principal ID of the Fine Collection Service.')
param fineCollectionServicePrincipalId string

// ------------------
// VARIABLES
// ------------------

var keyVaultSecretUserRoleGuid = '4633458b-17de-408a-b874-0445c86b69e6'

// ------------------
// RESOURCES
// ------------------

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

// License key secret used by Fine Collection Service
resource fineLicenseKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  tags: tags
  name: fineLicenseKeySecretName
  properties: {
    value: fineLicenseKeySecretValue
  }
}

resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, keyVault.id, fineCollectionServicePrincipalId, keyVaultSecretUserRoleGuid) 
  scope: fineLicenseKeySecret
  properties: {
    principalId: fineCollectionServicePrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretUserRoleGuid)
    principalType: 'ServicePrincipal'
  }
}
