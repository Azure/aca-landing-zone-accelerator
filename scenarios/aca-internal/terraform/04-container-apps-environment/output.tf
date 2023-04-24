output "aca_environment" {
  value = {
    id = azurerm_container_app_environment.aca_environment.id
    resource_group_name = azurerm_container_app_environment.aca_environment.resource_group_name
    default_domain = azurerm_container_app_environment.aca_environment.default_domain
  }
}

output "aca_environment_identity" {
  value = {
    id = azurerm_user_assigned_identity.identity_aca.id
  }
}
