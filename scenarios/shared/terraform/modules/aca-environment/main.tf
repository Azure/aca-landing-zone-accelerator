resource "azapi_resource" "container_apps_environment" {
  type                      = "Microsoft.App/managedEnvironments@2023-04-01-preview"
  name                      = var.environmentName
  parent_id                 = var.resourceGroupId
  location                  = var.location
  tags                      = var.tags
  response_export_values    = ["properties.defaultDomain", "properties.staticIp"]
  ignore_missing_property   = false
  schema_validation_enabled = true

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