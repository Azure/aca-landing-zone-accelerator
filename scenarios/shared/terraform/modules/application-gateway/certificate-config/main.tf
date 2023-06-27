data "azurerm_key_vault" "keyVault" {
  name                = var.keyVaultName
  resource_group_name = var.resourceGroupName
}

resource "azurerm_role_assignment" "keyvaultSecretUserRoleAssignment" {
  scope                = data.azurerm_key_vault.keyVault.id 
  principal_id         = var.appGatewayUserAssignedIdentityPrincipalId
  role_definition_name = "Key Vault Secrets User"
}

resource "azurerm_key_vault_secret" "sslCertSecret" {
  depends_on = [ azurerm_role_assignment.keyvaultSecretUserRoleAssignment ]
  name         = var.appGatewayCertificateKeyName
  key_vault_id = data.azurerm_key_vault.keyVault.id
  value        = var.appGatewayCertificateData
  content_type = "application/x-pkcs12"
}

