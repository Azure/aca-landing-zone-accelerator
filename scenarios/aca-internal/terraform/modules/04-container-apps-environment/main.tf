resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
}

module "naming" {
  source       = "../../../../shared/terraform/modules/naming"
  uniqueId     = random_string.random.result
  environment  = var.environment
  workloadName = var.workloadName
  location     = var.location
}

module "applicationInsights" {
  source            = "../../../../shared/terraform/modules/monitoring/app-insights"
  appInsightsName   = var.appInsightsName
  resourceGroupName = var.spokeResourceGroupName
  location          = var.location
  workspaceId       = var.logAnalyticsWorkspaceId
  tags              = var.tags
}

module "containerAppsEnvironment" {
  source                  = "../../../../shared/terraform/modules/aca-environment"
  environmentName         = module.naming.resourceNames["containerAppsEnvironment"]
  resourceGroupName       = var.spokeResourceGroupName
  location                = var.location
  logAnalyticsWorkspaceId = var.logAnalyticsWorkspaceId
  subnetId                = var.spokeInfraSubnetId
  workloadProfiles        = var.workloadProfiles
}

module "containerAppsEnvironmentPrivateDnsZone" {
  source            = "../../../../shared/terraform/modules/networking/private-zones"
  resourceGroupName = var.hubResourceGroupName
  zoneName          = module.containerAppsEnvironment.containerAppsEnvironmentDefaultDomain
  vnetLinks         = var.vnetLinks != [] ? var.vnetLinks : local.vnetLinks
  records = [
    {
      "name"        = "*"
      "ipv4Address" = [module.containerAppsEnvironment.containerAppsEnvironmentLoadBalancerIP]
    }
  ]
  tags = var.tags
}
