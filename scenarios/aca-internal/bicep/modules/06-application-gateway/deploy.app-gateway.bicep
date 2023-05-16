targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param workloadName string

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The FQDN of the Application Gateawy. Must match the TLS certificate.')
param applicationGatewayFqdn string

@description('The existing subnet resource ID to use for Application Gateway.')
param applicationGatewaySubnetId string

@description('The FQDN of the primary backend endpoint.')
param applicationGatewayPrimaryBackendEndFqdn string

@description('The path to use for Application Gateway\'s backend health probe.')
param appGatewayBackendHealthProbePath string = '/'

@description('Enable or disable Application Gateway certificate (PFX).')
param enableApplicationGatewayCertificate bool

@description('The name of the certificate key to use for Application Gateway certificate.')
param applicationGatewayCertificateKeyName string

@description('The resource ID of the exsiting Log Analytics workload for diagnostic settngs, or nothing if you don\'t need any.')
param applicationGatewayLogAnalyticsId string = ''

@description('The resource ID of the existing Key Vault which contains Application Gateway\'s cert.')
param keyVaultId string

// ------------------
// VARIABLES
// ------------------

var keyVaultIdTokens = split(keyVaultId, '/')

@description('The subscription ID of the existing Key Vault.')
var keyVaultSubscriptionId = keyVaultIdTokens[2]

@description('The name of the resource group containing the existing Key Vault.')
var keyVaultResourceGroupName = keyVaultIdTokens[4]

@description('The name of the existing Key Vault.')
var keyVaultName = keyVaultIdTokens[8]

@description('The existing PFX for Azure Application Gateway to use on its frontend.')
var applicationGatewayCertificatePath = 'configuration/acahello.demoapp.com.pfx'

// ------------------
// RESOURCES
// ------------------

@description('User-configured naming rules')
module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('06-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}

// TODO: Check if this is required if enableApplicationCertificate is false
@description('A user-assigned managed identity that enables Application Gateway to access Key Vault for its TLS certs.')
module userAssignedIdentity '../../../../shared/bicep/managed-identity.bicep' = {
  name: take('appGwUserAssignedIdentity-Deployment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    name: naming.outputs.resourcesNames.applicationGatewayUserAssignedIdentity
    location: location
    tags: tags
  }
}

// => Key Vault User Assigned Identity, Secret & Role Assignement for certificate
// As of today, App Gateway does not supports  "System Managed Identity" for Key Vault
// https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-secrets-user

// => Certificates (supports only 1 for now)

@description('Adds the PFX file into Azure Key Vault for consumption by Application Gateway.')
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

@description('Azure Application Gateway, which acts as the public Internet gateway and WAF for the workload.')
module appGatewayConfiguration './modules/app-gateway-config.bicep' = {
  name: take('appGatewayConfiguration-Deployment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    appGatewayName: naming.outputs.resourcesNames.applicationGateway
    location: location
    tags: tags
    appGatewayFqdn: applicationGatewayFqdn
    appGatewayPrimaryBackendEndFqdn: applicationGatewayPrimaryBackendEndFqdn
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

@description('The FQDN of the Azure Application Gateway.')
output applicationGatewayFqdn string = appGatewayConfiguration.outputs.applicationGatewayFqdn

@description('The public IP address of the Azure Application Gateway.')
output applicationGatewayPublicIp string = appGatewayConfiguration.outputs.applicationGatewayPublicIp
