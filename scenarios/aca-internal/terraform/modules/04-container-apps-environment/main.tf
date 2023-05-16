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

module "logAnalyticsWorkspace" {
  source            = "../../../../shared/terraform/modules/monitoring/log-analytics"
  resourceGroupName = var.resourceGroupName != "" ? var.resourceGroupName : module.naming.resourceNames["rgSpokeName"]
  location          = var.location
  workspaceName     = module.naming.resourceNames["logAnalyticsWorkspace"]
  tags              = var.tags
}

module "applicationInsights" {
  source            = "../../../../shared/terraform/modules/monitoring/app-insights"
  appInsightsName   = var.appInsightsName
  resourceGroupName = var.resourceGroupName != "" ? var.resourceGroupName : module.naming.resourceNames["rgSpokeName"]
  location          = var.location
  workspaceId       = module.logAnalyticsWorkspace.workspaceId
  tags              = var.tags
}

module "containerAppsEnvironment" {
  source                  = "../../../../shared/terraform/modules/aca-environment"
  environmentName         = module.naming.resourceNames["containerAppsEnvironment"]
  resourceGroupName       = var.resourceGroupName != "" ? var.resourceGroupName : module.naming.resourceNames["rgSpokeName"]
  location                = var.location
  logAnalyticsWorkspaceId = module.logAnalyticsWorkspace.workspaceId
  subnetId                = var.spokeInfraSubnetId
}

module "containerAppsEnvironmentPrivateDnsZone" {
  source            = "../../../../shared/terraform/modules/networking/private-zones"
  resourceGroupName = var.resourceGroupName != "" ? var.resourceGroupName : module.naming.resourceNames["rgSpokeName"]
  zoneName          = module.containerAppsEnvironment.containerAppsEnvironmentDefaultDomain
  vnetLinks         = var.vnetLinks != [] ? var.vnetLinks : local.vnetLinks
  records = [
    { "name"        = "*"
      "ipv4Address" = [module.containerAppsEnvironment.containerAppsEnvironmentLoadBalancerIP]
  }]
  tags = var.tags
}

