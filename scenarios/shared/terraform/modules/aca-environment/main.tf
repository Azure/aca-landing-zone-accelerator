resource "azapi_resource" "container_apps_environment" {
  type                      = "Microsoft.App/managedEnvironments@2023-04-01-preview"
  name                      = var.acaEnvironmentName
  parent_id                 = var.resourceGroupId
  location                  = var.location
  tags                      = var.tags
  response_export_values    = ["properties.defaultDomain", "properties.staticIp"] # ["*"] # 
  ignore_missing_property   = false
  schema_validation_enabled = true
  ignore_casing             = true

  body = jsonencode({
    properties = {
      zoneRedundant = false

      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.logAnalyticsWorkspaceCustomerId
          sharedKey  = var.logAnalyticsWorkspaceSharedKey # todo : required during creation, should be ignored later or it will recreate resources
        }
      }
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
    }
  })
  
  lifecycle {
    ignore_changes = [
      body
    ]
  }
}
