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
  source            = "../../../../shared/terraform/modules/networking/vnet"
  networkName       = module.naming.resourceNames["vnetHub"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.hubResourceGroup.name
  addressSpace      = var.vnetAddressPrefixes
  tags              = var.tags
  subnets = [
    {
      name            = var.gatewaySubnetName
      addressPrefixes = var.gatewaySubnetAddressPrefix
    }
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
  source                          = "../../../../shared/terraform/modules/firewall"
  firewallName                    = module.naming.resourceNames["firewall"]
  firewallPipName                 = module.naming.resourceNames["firewallPip"]
  firewallPipMgmtName             = module.naming.resourceNames["firewallPipMgmt"]
  firewallSubnetName              = var.azureFirewallSubnetName
  firewallSubnetAddressPrefix     = var.azureFirewallSubnetAddressPrefix
  firewallSubnetMgmtName          = var.azureFirewallSubnetMgmtName
  firewallSubnetMgmtAddressPrefix = var.azureFirewallSubnetMgmtAddressPrefix
  firewallSkuTier                 = var.firewallSkuTier
  resourceGroupName               = azurerm_resource_group.hubResourceGroup.name
  location                        = var.location
  vnetName                        = module.vnet.vnetName
  tags                            = var.tags
  applicationRuleCollections = [
    {
      name     = "allow-aca-rules"
      priority = 110
      action   = "Allow"

      rules = [
        {
          name = "allow-aca-controlplane"
          protocols = [
            {
              type = "Http"
              port = 80
            },
            {
              type = "Https"
              port = 443
          }]
          source_addresses = ["*"]
          destination_fqdns = [
            "mcr.microsoft.com",
            "*.data.mcr.microsoft.com",
            # "*.blob.${environment().suffixes.storage}" //NOTE: If you use ACR the endpoint must be added as well.
          ]
      }]
    }
  ]
}
