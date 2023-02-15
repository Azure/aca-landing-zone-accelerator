param keyVaultName string

@description('Array of name/value pairs')
param name string
param value string = ''
param serviceMetadata object

var deploy = (!empty(value) || !empty(serviceMetadata))
var secretValue = !empty(value) ? {
  value: value
} : serviceMetadata.type == 'storageAccount' ? {
  /* Storage Account */
  value: 'DefaultEndpointsProtocol=https;AccountName=${serviceMetadata.name};AccountKey=${listKeys(serviceMetadata.id, serviceMetadata.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
} : serviceMetadata.type == 'redisCache' ? {
  /* Redis Cache */
  value: '${serviceMetadata.name}.redis.cache.windows.net,abortConnect=false,ssl=true,password=${listKeys(serviceMetadata.id, serviceMetadata.apiVersion).primaryKey}'
} : serviceMetadata.type == 'serviceBus' ? {
  /* Service Bus */
  value: listKeys(resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', serviceMetadata.name, serviceMetadata.sasKeyName), serviceMetadata.apiVersion).primaryConnectionString
} : { 
  /* Unhandled type */
  value: '[[serviceMetadata.type "${serviceMetadata.type}" was unknown]]'
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = if (deploy) {
  name: '${keyVaultName}/${name}'
  properties: {
    value: secretValue.value
  }
}

output id string = keyVaultSecret.id
output name string = name
output type string = keyVaultSecret.type
output props object = keyVaultSecret.properties
output reference string = '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${name})'
