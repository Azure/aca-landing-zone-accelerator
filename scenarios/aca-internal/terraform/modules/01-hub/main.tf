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
  subnets = [
    {
      "name"            = var.gatewaySubnetName
      "addressPrefixes" = [var.gatewaySubnetAddressPrefix]
    },
    # {
    #   "name"            = var.azureFirewallSubnetName
    #   "addressPrefixes" = [var.azureFirewallSubnetAddressPrefix]
    # }
  ]
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

module "firewall" {
  source                = "../../../../shared/terraform/modules/firewall"
  vnetName              = module.vnet.vnetName
  # firewallSubnetName    = var.azureFirewallSubnetName # "${module.vnet.vnetId}/subnets/${var.azureFirewallSubnetName}" # module.vnet.firewallSubnetId.id # todo: enhance this
  vnetResourceGroupName = azurerm_resource_group.hubResourceGroup.name
  location              = var.location
  addressPrefixes       = [var.azureFirewallSubnetAddressPrefix]
  firewallName          = module.naming.resourceNames["firewall"]
  firewallPipName       = module.naming.resourceNames["firewallPip"]
  firewallSkuTier       = var.firewallSkuTier
  tags                  = var.tags
  # applicationRuleCollections = var.applicationRuleCollections
}
