output "helloWorldAppFQDN" {
  value = azurerm_container_app.helloWorld.latest_revision_fqdn
}