targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param applicationGatewayFQDN string

@description('The subnet resource id to use for Application Gateway.')
param applicationGatewaySubnetId string

@description('The FQDN of the primary backend endpoint.')
param applicationGatewayPrimaryBackendEndFQDN string

@description('The path to use for Application Gateway backend health probe.')
param appGatewayBackendHealthProbePath string = '/'

@description('Enable or disable Application Gateway Certificate (PFX).')
param enableApplicationGatewayCertificate bool

@description('The name of the certificate key to use for Application Gateway certificate.')
param applicationGatewayCertificateKeyName string

@description('Provide a resource ID of the Web Analytics WS if you need diagnostic settngs, or nothing if you don t need any.')
param applicationGatewayLogAnalyticsId string = ''

@description('The resource ID of the Key Vault.')
param keyVaultId string

// ------------------
// VARIABLES
// ------------------

var keyVaultIdTokens = split(keyVaultId, '/')
var keyVaultSubscriptionId = keyVaultIdTokens[2]
var keyVaultResourceGroupName = keyVaultIdTokens[4]
var keyVaultName = keyVaultIdTokens[8]

var applicationGatewayCertificatePath = 'configuration/acahello.demoapp.com.pfx'

// ------------------
// RESOURCES
// ------------------

module naming '../modules/naming/naming.module.bicep' = {
  name: take('06-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    location: location
  }
}

// TODO: Check if this is required if enableApplicationCertificate is false
module userAssignedIdentity '../modules/managed-identity.bicep' = {
  name: take('appGwUserAssignedIdentity-Deployment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    name: naming.outputs.resourcesNames.applicationGatewayUserAssignedIdentity
    location: location
    tags: tags
  }
}

// => Key Vault User Assigned Identity, Secret & Role Assignement for certificate
// As of today, App Gateway does not supports  "System Managed Identity" for Key Vault
// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user

// => Certificates (supports only 1 for now)

module appGatewayAddCertificates './modules/app-gateway-cert.bicep' = if (enableApplicationGatewayCertificate) {
  name: take('appGatewayAddCertificates-Deployment-${uniqueString(resourceGroup().id)}', 64)
  scope: resourceGroup(keyVaultSubscriptionId, keyVaultResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    appGatewayCertificateData: loadFileAsBase64(applicationGatewayCertificatePath)
    appGatewayCertificateKeyName: applicationGatewayCertificateKeyName
    appGatewayUserAssignedIdentityPrincipalId: userAssignedIdentity.outputs.principalId
  }
}

module appGatewayConfiguration './modules/app-gateway-config.bicep'= {
  name: take('appGatewayConfiguration-Deployment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    appGatewayName: naming.outputs.resourcesNames.applicationGateway
    location: location
    tags: tags
    appGatewayFQDN: applicationGatewayFQDN
    appGatewayPrimaryBackendEndFQDN: applicationGatewayPrimaryBackendEndFQDN
    appGatewayBackendHealthProbePath: appGatewayBackendHealthProbePath
    appGatewayPublicIpName: naming.outputs.resourcesNames.applicationGatewayPip
    appGatewaySubnetId: applicationGatewaySubnetId
    appGatewayUserAssignedIdentityId: userAssignedIdentity.outputs.id
    keyVaultSecretId: (enableApplicationGatewayCertificate) ? appGatewayAddCertificates.outputs.SecretUri : ''
    appGatewayLogAnalyticsId: applicationGatewayLogAnalyticsId
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The FQDN of the application gateway.')
output applicationGatewayFqdn string = appGatewayConfiguration.outputs.applicationGatewayFqdn

@description('The public IP address of the application gateway.')
output applicationGatewayPublicIp string = appGatewayConfiguration.outputs.applicationGatewayPublicIp
