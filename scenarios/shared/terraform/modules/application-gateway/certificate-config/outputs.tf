output "SecretUri" {
  value = "https://${data.azurerm_key_vault.keyVault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.sslCertSecret.name}"
}