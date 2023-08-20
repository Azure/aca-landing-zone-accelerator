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
          transport     = "Auto"
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