var workload =                      'example'
var environment =                   'prod'
var location =                      'southcentralus'
var appgwFqdn =                     'api.contoso.com'
var apimRG =                        'ES-AppGateway_RG'
var keyVaultName =                  'kv-${workload}-${environment}-002'
var certPassword =                  '123456'

var appGatewayIdentityId            = 'identity-bjdcsacloud'

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     appGatewayIdentityId
  location: location
}

module certificate '../modules/certificate.bicep' = {
  name: 'certificate'
  scope: resourceGroup(apimRG)
  params: {
    appGatewayFQDN:                 appgwFqdn
    location:                       location
    keyVaultName:                   keyVaultName
    certPassword:                   certPassword
    managedIdentity:                appGatewayIdentity
  }
}


