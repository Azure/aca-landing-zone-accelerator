resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
}

module "naming" {
  source       = "../../../../shared/terraform/modules/naming"
  uniqueId     = random_string.random.result
  environment  = var.environment
  workloadName = var.workloadName
  location     = var.location
}

resource "azurerm_user_assigned_identity" "appGatewayUserIdentity" {
  name                = module.naming.resourceNames["applicationGatewayUserAssignedIdentity"]
  location            = var.location
  resource_group_name = var.resourceGroupName # module.naming.resourceNames["rgSpokeName"]
  tags                = var.tags
}

module "appGatewayAddCertificates" {
  source                                    = "../../../../shared/terraform/modules/application-gateway/certificate-config"
  keyVaultName                              = var.keyVaultName
  resourceGroupName                         = var.resourceGroupName
  appGatewayCertificateKeyName              = var.appGatewayCertificateKeyName
  appGatewayCertificateData                 = local.appGatewayCertificate
  appGatewayUserAssignedIdentityPrincipalId = azurerm_user_assigned_identity.appGatewayUserIdentity.principal_id
}

module "appGatewayConfiguration" {
  source                           = "../../../../shared/terraform/modules/application-gateway/gateway-config"
  appGatewayName                   = module.naming.resourceNames["applicationGateway"]
  resourceGroupName                = var.resourceGroupName
  location                         = var.location
  diagnosticSettingName            = "agw-diagnostics"
  appGatewayFQDN                   = var.appGatewayFQDN
  appGatewayPrimaryBackendEndFQDN  = var.appGatewayPrimaryBackendEndFQDN
  appGatewayPublicIpName           = module.naming.resourceNames["applicationGatewayPip"]
  appGatewaySubnetId               = var.appGatewaySubnetId
  appGatewayUserAssignedIdentityId = azurerm_user_assigned_identity.appGatewayUserIdentity.id
  keyVaultSecretId                 = module.appGatewayAddCertificates.SecretUri
  appGatewayLogAnalyticsId         = var.appGatewayLogAnalyticsId
  tags                             = var.tags
}

module "diagnostics" {
  source = "../../../../shared/terraform/modules/diagnostics"
  logAnalyticsWorkspaceId = var.logAnalyticsWorkspaceId
  resources = [
    {
      "type" = "agw"
      "id"   = module.appGatewayConfiguration.applicationGatewayId
    }
  ]
}