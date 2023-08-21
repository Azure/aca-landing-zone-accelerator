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
  source                  = "../../../../shared/terraform/modules/monitoring/app-insights"
  appInsightsName         = var.appInsightsName
  resourceGroupName       = var.spokeResourceGroupName
  location                = var.location
  logAnalyticsWorkspaceId = var.logAnalyticsWorkspaceId
  tags                    = var.tags
}

module "containerAppsEnvironment" {
  source                          = "../../../../shared/terraform/modules/aca-environment"
  acaEnvironmentName              = module.naming.resourceNames["containerAppsEnvironment"]
  resourceGroupName               = var.spokeResourceGroupName
  resourceGroupId                 = var.spokeResourceGroupId
  location                        = var.location
  logAnalyticsWorkspaceCustomerId = var.logAnalyticsWorkspaceCustomerId
  logAnalyticsWorkspaceSharedKey  = var.logAnalyticsWorkspaceSharedKey
  subnetId                        = var.spokeInfraSubnetId
  tags                            = var.tags
}

module "containerAppsEnvironmentPrivateDnsZone" {
  source            = "../../../../shared/terraform/modules/networking/private-zones"
  resourceGroupName = var.hubResourceGroupName
  zoneName          = module.containerAppsEnvironment.containerAppsEnvironmentDefaultDomain
  vnetLinks         = var.vnetLinks != [] ? var.vnetLinks : local.vnetLinks
  tags              = var.tags

  records = [
    {
      name        = "*"
      ipv4Address = [module.containerAppsEnvironment.containerAppsEnvironmentLoadBalancerIP]
  }]
}

