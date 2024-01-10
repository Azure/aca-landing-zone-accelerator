resource "azurerm_public_ip" "publicIpFirewall" {
  name                = var.publicIpFirewallName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = var.tags
}

resource "azurerm_public_ip" "publicIpFirewallManagement" {
  name                = var.publicIpFirewallManagementName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = var.tags
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewallName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  sku_name            = "AZFW_VNet" # AZFW_Hub
  sku_tier            = "Basic"     # "Standard"  # Premium  # "Basic" # 
  firewall_policy_id  = azurerm_firewall_policy.firewallPolicy.id
  zones               = ["1"] # ["1", "2", "3"]
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnetFirewallId
    public_ip_address_id = azurerm_public_ip.publicIpFirewall.id
  }

  management_ip_configuration { # Firewall with Basic SKU must have Management Ip configuration
    name                 = "mgmtconfig"
    subnet_id            = var.subnetFirewallManagementId
    public_ip_address_id = azurerm_public_ip.publicIpFirewallManagement.id
  }
}

resource "azurerm_firewall_policy" "firewallPolicy" {
  name                = var.firewallPolicyName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  sku                 = "Basic" # "Standard" # "Premium" #
}

resource "azurerm_firewall_policy_rule_collection_group" "policyGroupDeny" {
  name               = "policyGroupDeny"
  firewall_policy_id = azurerm_firewall_policy.firewallPolicy.id
  priority           = 100

  application_rule_collection {
    name     = "app_rules_deny_yahoo_com_any_source"
    priority = 100
    action   = "Deny"

    rule {
      name = "deny_yahoo_com"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"] # local.cidr_subnet_aks_nodes_pods # azurerm_subnet.subnet_mgt.address_prefixes
      destination_fqdns = ["*.yahoo.com"]
    }
  }

  # allow raw.githubusercontent.com, to get the custom scripts to install to VMs
  application_rule_collection {
    name     = "app_rules_allow_githubusercontent_any_source"
    priority = 101
    action   = "Allow"

    rule {
      name = "allow_githubusercontent_com"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"] # local.cidr_subnet_aks_nodes_pods # azurerm_subnet.subnet_mgt.address_prefixes
      destination_fqdns = ["raw.githubusercontent.com"]
    }
  }
}
