output "helloWorldAppFQDN" {
  value = jsondecode(azapi_resource.container_app.0.output).properties.latestRevisionFqdn
 # azurerm_container_app.helloWorld[0].latest_revision_fqdn
}