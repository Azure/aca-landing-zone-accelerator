resource "azurerm_public_ip" "publicIpFirewall" {
  name                = var.publicIpFirewallName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.firewallAvailabilityZones
  tags                = var.tags
}

resource "azurerm_public_ip" "publicIpFirewallManagement" {
  name                = var.publicIpFirewallManagementName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.firewallAvailabilityZones
  tags                = var.tags
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewallName
  resource_group_name = var.hubResourceGroupName
  location            = var.location
  sku_name            = var.firewallSkuName
  sku_tier            = var.firewallSkuTier
  firewall_policy_id  = azurerm_firewall_policy.firewallPolicy.id
  zones               = var.firewallAvailabilityZones
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
  sku                 = var.firewallSkuTier
}

resource "azurerm_firewall_policy_rule_collection_group" "policyGroup" {
  for_each = try({ for group in var.firewallPolicyRuleCollectionGroups : group.name => group }, toset([]))

  name               = each.value.name
  priority           = each.value.priority
  firewall_policy_id = azurerm_firewall_policy.firewallPolicy.id

  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collections

    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules

        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_fqdns     = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols

            content {
              port = protocols.value.port
              type = protocols.value.type
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collections

    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules

        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_ports     = rule.value.destination_ports
          destination_addresses = rule.value.destination_addresses
          destination_ip_groups = rule.value.destination_ip_groups
          destination_fqdns     = rule.value.destination_fqdns
          protocols             = rule.value.protocols
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collections
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules

        content {
          name               = rule.value.name
          source_addresses   = rule.value.source_addresses
          source_ip_groups   = rule.value.source_ip_groups
          destination_ports  = rule.value.destination_ports
          translated_address = rule.value.translated_address
          translated_port    = rule.value.translated_port
          protocols          = rule.value.protocols
        }
      }
    }

  }
}
