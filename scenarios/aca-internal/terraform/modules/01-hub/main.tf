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
      name            = var.gatewaySubnetName
      addressPrefixes = [var.gatewaySubnetAddressPrefix]
    },
    {
      name            = var.azureFirewallSubnetName
      addressPrefixes = [var.azureFirewallSubnetAddressPrefix]
    },
    {
      name            = var.azureFirewallSubnetManagementName
      addressPrefixes = [var.azureFirewallSubnetManagementAddressPrefix]
    }
  ]
}

module "firewall" {
  source                             = "../../../../shared/terraform/modules/firewall"
  firewallName                       = module.naming.resourceNames["firewall"]
  location                           = var.location
  hubResourceGroupName               = azurerm_resource_group.hubResourceGroup.name
  subnetFirewallId                   = module.vnet.subnetIds[var.azureFirewallSubnetName]
  subnetFirewallManagementId         = module.vnet.subnetIds[var.azureFirewallSubnetManagementName]
  publicIpFirewallName               = module.naming.resourceNames["firewallPip"]
  publicIpFirewallManagementName     = module.naming.resourceNames["firewallManagementPip"]
  firewallPolicyName                 = module.naming.resourceNames["firewallPolicy"]
  firewallPolicyRuleCollectionGroups = local.firewallPolicyRuleCollectionGroups
  tags                               = var.tags
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

module "logAnalyticsWorkspace" {
  source            = "../../../../shared/terraform/modules/monitoring/log-analytics"
  resourceGroupName = azurerm_resource_group.hubResourceGroup.name
  location          = var.location
  workspaceName     = module.naming.resourceNames["logAnalyticsWorkspace"]
  tags              = var.tags
}

module "diagnostics" {
  source                  = "../../../../shared/terraform/modules/diagnostics"
  logAnalyticsWorkspaceId = module.logAnalyticsWorkspace.workspaceId
  resources = [
    {
      type = "firewall-hub"
      id   = module.firewall.firewallId
    },
    {
      type = "vnet-hub"
      id   = module.vnet.vnetId
    },
    {
      type = "bastion"
      id   = module.bastion.bastionHostId
    }
  ]
}
