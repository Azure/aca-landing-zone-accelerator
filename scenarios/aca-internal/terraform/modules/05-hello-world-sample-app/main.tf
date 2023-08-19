// Create a container app 
// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2022-11-01-preview/containerapps?pivots=deployment-language-terraform

resource "azapi_resource" "container_app" {
  type                      = "Microsoft.App/containerApps@2023-04-01-preview"
  count                     = var.deployApp ? 1 : 0
  name                      = var.helloWorldContainerAppName
  parent_id                 = var.resourceGroupId
  location                  = var.location
  tags                      = var.tags
  response_export_values    = ["properties.latestRevisionFqdn"]
  ignore_missing_property   = false
  schema_validation_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [var.containerRegistryUserAssignedIdentityId]
  }

  body = jsonencode({
    properties = {
      environmentId       = var.containerAppsEnvironmentId,
      workloadProfileName = "Consumption"
      configuration = {
        activeRevisionsMode = "Single"
        ingress = {
          allowInsecure = false,
          external      = true,
          targetPort    = 80,
          transport     = "auto"
          traffic = [
            {
              latestRevision = true,
              weight         = 100
            }
          ],
        },
      },
      template = {
        containers = [
          {
            name  = "simple-hello"
            image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            resources = {
              cpu    = 0.25
              memory = "0.5Gi"
            },
          }
        ],
        scale = {
          minReplicas = 1,
          maxReplicas = 10,
        },
      }
    }
  })
}

# resource "azurerm_container_app" "helloWorld" {
#   count                        = var.deployApp ? 1 : 0
#   name                         = var.helloWorldContainerAppName
#   resource_group_name          = var.resourceGroupName
#   container_app_environment_id = var.containerAppsEnvironmentId
#   tags                         = var.tags

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [var.containerRegistryUserAssignedIdentityId]
#   }

#   revision_mode = "Single"

#   ingress {
#     allow_insecure_connections = false
#     external_enabled           = true
#     target_port                = 80
#     transport                  = "auto"

#     traffic_weight {
#       latest_revision = true
#       percentage      = 100
#     }
#   }

#   template {
#     container {
#       name   = "simple-hello"
#       cpu    = "0.25"
#       memory = "0.5Gi"
#       image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
#     }

#     min_replicas = 1
#     max_replicas = 10
#   }
# }
