resource "azurerm_container_app_environment" "environment" {
  name                           = var.environmentName
  resource_group_name            = var.resourceGroupName
  location                       = var.location
  log_analytics_workspace_id     = var.logAnalyticsWorkspaceId
  infrastructure_subnet_id       = var.subnetId
  internal_load_balancer_enabled = true
}

# resource "azurerm_container_app_environment_dapr_component" "daprComponent" {
#   container_app_environment_id = azurerm_container_app_environment.environment.id
#   name = var.daprName
#   type = ""
#   version = ""
# }