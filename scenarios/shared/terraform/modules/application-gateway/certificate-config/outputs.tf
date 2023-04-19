//TODO: Should be Uri here. 
output "SecretUri" {
  value = azurerm_key_vault_secret.sslCertSecret.value
}