data "azurerm_key_vault" "keyVault" {
  name = var.keyVaultName
}

resource "azurerm_key_vault_secret" "sslCertSecret" {
  key_vault_id = data.azurerm_key_vault.keyVault.id
  value = var.appGatewayCertificateKeyName
  content_type = "application/x-pkcs12"
}

resource "azurerm_role_assignment" "keyvaultSecretUserRoleAssignment" {
  scope = azurerm_key_vault_secret.sslCertSecret.id
  principal_id = var.appGatewayUserAssignedIdentityPrincipalId
  role_definition_name = "Key Vault Secrets User"
}