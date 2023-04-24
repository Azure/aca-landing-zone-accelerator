resource "azurerm_container_app" "aca" {
  name                         = "aca-app"
  container_app_environment_id = data.terraform_remote_state.container_apps_environment.outputs.aca_environment.id
  resource_group_name          = data.terraform_remote_state.container_apps_environment.outputs.aca_environment.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.terraform_remote_state.container_apps_environment.outputs.aca_environment_identity.id
    ]
  }

  ingress {
    external_enabled           = true
    allow_insecure_connections = false
    target_port                = 80
    transport                  = "auto"
    traffic_weight {
      label      = "examplecontainerapp"
      percentage = 100
    }
  }

  template {
    container {
      name   = "simple-hello"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    min_replicas = 1
    max_replicas = 10
    # volume {}
  }

  # dapr {}
  # registry {}
}
