output "helloWorldAppFQDN" {
  value = jsondecode(azapi_resource.container_app.0.output).properties.latestRevisionFqdn
}