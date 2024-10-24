resource "azurerm_container_app" "helloWorld" {
  count                        = var.deployApp ? 1 : 0
  name                         = var.helloWorldContainerAppName
  resource_group_name          = var.resourceGroupName
  container_app_environment_id = var.containerAppsEnvironmentId
  tags                         = var.tags
  # workload_profile_name        = var.workloadProfileName

  identity {
    type         = "UserAssigned"
    identity_ids = [var.containerRegistryUserAssignedIdentityId]
  }

  revision_mode = "Single"

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "simple-hello"
      cpu    = "0.25"
      memory = "0.5Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    }

    min_replicas = 1
    max_replicas = 10
  }
}
