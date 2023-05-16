data "azurerm_key_vault" "keyVault" {
  name                = var.keyVaultName
  resource_group_name = var.resourceGroupName
}

resource "azurerm_key_vault_secret" "sslCertSecret" {
  name         = var.appGatewayCertificateKeyName
  key_vault_id = data.azurerm_key_vault.keyVault.id
  value        = var.appGatewayCertificateData
  content_type = "application/x-pkcs12"
}

resource "azurerm_role_assignment" "keyvaultSecretUserRoleAssignment" {
  scope                = data.azurerm_key_vault.keyVault.id # "/subscriptions/${data.azurerm_client_config.current.subscription_id}/${azurerm_key_vault_secret.sslCertSecret.id}" 
  principal_id         = var.appGatewayUserAssignedIdentityPrincipalId
  role_definition_name = "Key Vault Secrets User"
}