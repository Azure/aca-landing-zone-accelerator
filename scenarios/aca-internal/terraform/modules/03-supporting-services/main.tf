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

module "containerRegistry" {
  source                                    = "../../../../shared/terraform/modules/acr"
  acrName                                   = module.naming.resourceNames["containerRegistry"]
  spokeResourceGroupName                    = var.spokeResourceGroupName
  hubResourceGroupName                      = var.hubResourceGroupName
  location                                  = var.location
  vnetLinks                                 = var.vnetLinks != [] ? var.vnetLinks : local.vnetLinks
  aRecords                                  = var.aRecords
  subnetId                                  = var.spokePrivateEndpointSubnetId
  containerRegistryUserAssignedIdentityName = module.naming.resourceNames["containerRegistryUserAssignedIdentity"]
  containerRegistryPullRoleAssignment       = var.containerRegistryPullRoleAssignment
  containerRegistryPep                      = module.naming.resourceNames["containerRegistryPep"]
  tags                                      = var.tags
}


module "keyVault" {
  source                           = "../../../../shared/terraform/modules/keyvault"
  spokeResourceGroupName           = var.spokeResourceGroupName
  hubResourceGroupName             = var.hubResourceGroupName
  keyVaultName                     = module.naming.resourceNames["keyVault"]
  location                         = var.location
  vnetLinks                        = var.vnetLinks != [] ? var.vnetLinks : local.vnetLinks
  aRecords                         = var.aRecords
  subnetId                         = var.spokePrivateEndpointSubnetId
  keyVaultUserAssignedIdentityName = module.naming.resourceNames["keyVaultUserAssignedIdentity"]
  keyVaultPullRoleAssignment       = var.keyVaultPullRoleAssignment
  keyVaultPep                      = module.naming.resourceNames["keyVaultPep"]
  clientIP                         = var.clientIP
  tags                             = var.tags
}

module "diagnostics" {
  source                  = "../../../../shared/terraform/modules/diagnostics"
  logAnalyticsWorkspaceId = var.logAnalyticsWorkspaceId
  resources = [
    {
      type = "keyvault"
      id   = module.keyVault.keyVaultId
    },
    {
      type = "acr"
      id   = module.containerRegistry.acrId
    }
  ]
}