resource "azapi_resource" "container_apps_environment" {
  type                      = "Microsoft.App/managedEnvironments@2023-04-01-preview"
  name                      = var.environmentName
  parent_id                 = var.resourceGroupId
  location                  = var.location
  tags                      = var.tags
  response_export_values    = ["properties.defaultDomain", "properties.staticIp"]
  ignore_missing_property   = false
  schema_validation_enabled = false

  body = jsonencode({
    properties = {
      # appLogsConfiguration = { # todo: add app logs configuration
      #   destination = "log-analytics"
      #   logAnalyticsConfiguration = {
      #     customerId = var.logAnalyticsWorkspaceId # var.container_apps_environment.log_analytics.workspace_id
      #     # sharedKey  = var.logAnalyticsSharedKey   # var.container_apps_environment.log_analytics.shared_key
      #   }
      # }
      vnetConfiguration = {
        infrastructureSubnetId = var.subnetId
        internal               = true
      }
      workloadProfiles = [
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
        }
        # for profile in var.container_apps_environment.workload_profiles :
        # {
        #   maximumCount        = profile.maximum_count
        #   minimumCount        = profile.minimum_count
        #   name                = profile.name
        #   workloadProfileType = profile.workload_profile_type
        # }
      ]
      zoneRedundant = false
    }
  })
}

# module "container_apps" {
#   for_each          = { for app in var.container_apps : app.name => app }
#   source            = "../../modules/container-app"
#   location          = local.resource_group_location
#   resource_group_id = local.resource_group_id
#   tags              = local.tags

#   name                         = format("ca-%s-%s", each.value.name, local.resource_suffix_kebabcase)
#   workload_profile_name        = each.value.workload_profile_name
#   container_app_environment_id = azapi_resource.container_apps_environment.id
#   revision_mode                = each.value.revision_mode

#   template   = each.value.template
#   ingress    = each.value.ingress
#   identity   = each.value.identity
#   registries = each.value.registries

#   # container_app_secrets          = var.container_app_secrets
# }

# resource "azurerm_container_app_environment" "environment" {
#   name                           = var.environmentName
#   resource_group_name            = var.resourceGroupName
#   location                       = var.location
#   log_analytics_workspace_id     = var.logAnalyticsWorkspaceId
#   infrastructure_subnet_id       = var.subnetId
#   internal_load_balancer_enabled = true
# }

# resource "azurerm_container_app_environment_dapr_component" "daprComponent" {
#   container_app_environment_id = azurerm_container_app_environment.environment.id
#   name = var.daprName
#   type = ""
#   version = ""
# }
