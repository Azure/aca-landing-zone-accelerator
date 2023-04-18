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

resource "azurerm_resource_group" "supportingServices" {
  name     = var.resourceGroupName
  location = var.location
  tags     = var.tags
}

module "containerRegistry" {
  source                                    = "../../../../shared/terraform/modules/acr"
  acrName                                   = module.naming.resourceNames["containerRegistry"]
  resourceGroupName                         = azurerm_resource_group.supportingServices.name
  location                                  = var.location
  vnetLinks                                 = local.vnetLinks
  aRecords                                  = var.aRecords
  subnetId                                  = var.spokePrivateEndpointSubnetId
  containerRegistryUserAssignedIdentityName = module.naming.resourceNames["containerRegistryUserAssignedIdentity"]
  containerRegistryPullRoleAssignment       = var.containerRegistryPullRoleAssignment
  containerRegistryPep                      = module.naming.resourceNames["containerRegistryPep"]
  tags                                      = var.tags
}


# module "keyVault" {
#   source = "../../../../shared/terraform/modules/keyvault"
# }

