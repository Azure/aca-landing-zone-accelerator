output "helloWorldAppFQDN" {
  value = azurerm_container_app.helloWorld[0].latest_revision_fqdn
}