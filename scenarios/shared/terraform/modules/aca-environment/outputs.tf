output "containerAppsEnvironmentName" {
  value = azurerm_container_app_environment.environment.name
}

output "containerAppsEnvironmentId" {
  value = azurerm_container_app_environment.environment.id
}

output "containerAppsEnvironmentDefaultDomain" {
  value = azurerm_container_app_environment.environment.default_domain
}

output "containerAppsEnvironmentLoadBalancerIP" {
  value = azurerm_container_app_environment.environment.static_ip_address
}