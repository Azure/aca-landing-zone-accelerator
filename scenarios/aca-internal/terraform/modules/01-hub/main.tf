resource "random_string" "random" {
  length = 5
}

module "naming" {
  source       = "../../../../shared/terraform/modules/naming"
  uniqueId     = random_string.random.result
  environment  = var.environment
  workloadName = var.workloadName
  location     = var.location
}

resource "azurerm_resource_group" "hubResourceGroup" {
  name     = var.hubResourceGroupName != "" ? var.hubResourceGroupName : module.naming.resourceNames["rgHubName"]
  location = var.location
  tags     = var.tags
}


module "vnet" {
  source               = "../../../../shared/terraform/modules/networking/vnet"
  networkName          = module.naming.resourceNames["vnetHub"]
  location             = var.location
  resourceGroupName    = azurerm_resource_group.hubResourceGroup.name
  addressSpace         = var.vnetAddressPrefixes
  tags                 = var.tags
  ddosProtectionPlanId = var.ddosProtectionPlanId
  subnets = [{ "addressPrefixes" = tolist([var.vmJumpBoxSubnetAddressPrefix])
  "name" = var.vmSubnetName }]
}

module "bastion" {
  source                = "../../../../shared/terraform/modules/bastion"
  vnetName              = module.vnet.vnetName
  vnetResourceGroupName = azurerm_resource_group.hubResourceGroup.name
  location              = var.location
  bastionNsgName        = module.naming.resourceNames["bastionNsg"]
  addressPrefixes       = var.bastionSubnetAddressPrefixes
  bastionPipName        = module.naming.resourceNames["bastionPip"]
  tags                  = var.tags
  bastionHostName       = module.naming.resourceNames["bastion"]
}

module "vm" {
  source                = "../../../../shared/terraform/modules/vms"
  osType                = "Linux"
  nsgName               = module.naming.resourceNames["vmJumpBoxNsg"]
  location              = var.location
  vnetName              = module.vnet.vnetId
  tags                  = var.tags
  vnetResourceGroupName = azurerm_resource_group.hubResourceGroup.name
  addressPrefixes       = tolist([var.vmJumpBoxSubnetAddressPrefix])
  securityRules         = var.securityRules
  nicName               = module.naming.resourceNames["vmJumpBoxNic"]
  vmName                = module.naming.resourceNames["vmJumpBox"]
  adminUsername         = var.vmAdminUsername
  adminPassword         = var.vmAdminPassword
  resourceGroupName     = azurerm_resource_group.hubResourceGroup.name
  size                  = var.vmSize
  vmSubnetName          = var.vmSubnetName
}