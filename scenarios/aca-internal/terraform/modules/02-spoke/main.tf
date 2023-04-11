resource "random_string" "random" {
  length = 5
  special = false
  lower = true
}

module "naming" {
  source       = "../../../../shared/terraform/modules/naming"
  uniqueId     = random_string.random.result
  environment  = var.environment
  workloadName = var.workloadName
  location     = var.location
}

resource "azurerm_resource_group" "spokeResourceGroup" {
  name     = var.spokeResourceGroupName != "" ? var.spokeResourceGroupName : module.naming.resourceNames["rgSpokeName"]
  location = var.location
  tags     = var.tags
}


module "vnet" {
  source               = "../../../../shared/terraform/modules/networking/vnet"
  networkName          = module.naming.resourceNames["vnetSpoke"]
  location             = var.location
  resourceGroupName    = azurerm_resource_group.spokeResourceGroup.name
  addressSpace         = var.vnetAddressPrefixes
  tags                 = var.tags
  subnets = [{ "addressPrefixes" = tolist([var.infraSubnetAddressPrefix])
  "name" = var.infraSubnetName }]
}

module "nsgContainerAppsEnvironment" {
  source = "../../../../shared/terraform/modules/networking/nsg"
  nsgName           = var.caeNsgName
  location          = var.location
  resourceGroupName = var.spokeResourceGroupName
  securityRules     = var.securityRules
  tags              = var.tags
}

module "peeringSpokeToHub" {
  source = "../../../../shared/terraform/modules/networking/peering"
  localVnetName = module.vnet.vnetName
  remoteVnetId = var.hubVnetId
  remoteVnetName = locals.hubVnetName


}

module "peeringHubToSpoke" {
  source = "../../../../shared/terraform/modules/networking/peering"
  localVnetName = local.hubVnetName
  remoteVnetId = module.vnet.vnetId
  remoteVnetName = local.hubVnetName
}

