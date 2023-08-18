resource "azurerm_subnet" "firewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.vnetResourceGroupName
  virtual_network_name = var.vnetName
  address_prefixes     = var.addressPrefixes
}

resource "azurerm_public_ip" "firewallPip" {
  name                = var.firewallPipName
  location            = var.location
  resource_group_name = var.vnetResourceGroupName

  sku      = "Standard"
  sku_tier = "Regional"

  allocation_method = "Static"
  zones             = ["1"] # ["1", "2", "3"]

  tags = var.tags
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewallName
  location            = var.location
  resource_group_name = var.vnetResourceGroupName
  sku_name            = "AZFW_VNet" # AZFW_Hub
  sku_tier            = var.firewallSkuTier
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id
  zones               = ["1"] # ["1", "2", "3"]
  tags                = var.tags
  # dns_servers         = ["168.63.129.16"]
  # threat_intel_mode = "Alert" # Off, Alert,Deny and ""(empty string). Defaults to Alert.

  ip_configuration {
    name                 = "ipconf"
    subnet_id            = azurerm_subnet.firewallSubnet.id
    public_ip_address_id = azurerm_public_ip.firewallPip.id
  }

  # dynamic "management_ip_configuration" { # Firewall with Basic SKU must have Management Ip configuration
  #   for_each = var.firewall_sku_tier == "Basic" ? ["any_value"] : []
  #   content {
  #     name                 = "mgmtconfig"
  #     subnet_id            = azurerm_subnet.subnet_firewall_mgmt.0.id
  #     public_ip_address_id = azurerm_public_ip.public_ip_firewall_mgmt.0.id
  #   }
  # }
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "firewall-policy"
  resource_group_name = var.vnetResourceGroupName
  location            = var.location
  sku                 = var.firewallSkuTier
}

resource "azurerm_firewall_policy_rule_collection_group" "policy_group_aca" {
  name               = "policy-group-aca"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 100

  application_rule_collection {
    name     = "allow-aca-rules"
    priority = 110
    action   = "Allow"

    rule {
      name = "allow-aca-controlplane"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["*"]
      destination_fqdns = [
        "mcr.microsoft.com",
        "*.data.mcr.microsoft.com",
        # "*.blob.${environment().suffixes.storage}" //NOTE: If you use ACR the endpoint must be added as well.
      ]
    }
  }
}

# todo: create lock on firewall

# todo: disgnostic settings for firewall

