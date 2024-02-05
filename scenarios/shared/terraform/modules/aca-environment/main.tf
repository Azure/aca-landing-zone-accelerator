resource "azurerm_container_app_environment" "environment" {
  name                           = var.environmentName
  resource_group_name            = var.resourceGroupName
  location                       = var.location
  log_analytics_workspace_id     = var.logAnalyticsWorkspaceId
  infrastructure_subnet_id       = var.subnetId
  internal_load_balancer_enabled = true

  dynamic "workload_profile" {
    for_each = var.workloadProfiles

    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }
}

# resource "azurerm_container_app_environment_dapr_component" "daprComponent" {
#   container_app_environment_id = azurerm_container_app_environment.environment.id
#   name = var.daprName
#   type = ""
#   version = ""
# }
