targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the Key Vault.')
param keyVaultName string

@description('The name of the secret containing the SendGrid API key value for the Backend Background Processor Service.')
param sendGridKeySecretName string

@description('The SendGrid API key for for Backend Background Processor Service.')
@secure()
param sendGridKeySecretValue string

@description('The name of the secret containing the External Azure Sorage Access key for the Backend Background Processor Service.')
param externalAzureStorageKeySecretName string

@description('The External Azure Stroage Access key for the Backend Background Processor Service.')
@secure()
param externalAzureStorageKeySecretValue string

@description('The principal ID of the Backend Processor Service.')
param backendProcessorServicePrincipalId string

// ------------------
// VARIABLES
// ------------------

var keyVaultSecretUserRoleGuid = '4633458b-17de-408a-b874-0445c86b69e6'

var sendGridKey = empty(sendGridKeySecretValue) ? 'dummy' : sendGridKeySecretValue

// ------------------
// RESOURCES
// ------------------

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

// Send Grid API key secret used by Backend Background Processor Service.
resource sendGridKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  tags: tags
  name: sendGridKeySecretName
  properties: {
    value: sendGridKey
  }
}

// External Azure storage key secret used by Backend Background Processor Service.
resource externalAzureStorageKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  tags: tags
  name: externalAzureStorageKeySecretName
  properties: {
    value: externalAzureStorageKeySecretValue
  }
}

resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, keyVault.id, backendProcessorServicePrincipalId, keyVaultSecretUserRoleGuid) 
  scope: keyVault
  properties: {
    principalId: backendProcessorServicePrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretUserRoleGuid)
    principalType: 'ServicePrincipal'
  }
}
