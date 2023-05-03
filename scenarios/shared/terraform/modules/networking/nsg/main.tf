resource "azurerm_network_security_group" "securityGroup" {
  name                = var.nsgName
  resource_group_name = var.resourceGroupName
  location            = var.location
  tags                = var.tags

  # dynamic "security_rule" {
  #     for_each = { for rule in var.securityRules: rule.name => rule }
  #         content {
  #             name = each.value.name
  #             description = each.value.description
  #             protocol = each.value.protocol
  #             source_address_prefix = each.value.sourceAddressPrefix
  #             source_port_range = each.value.sourcePortRange
  #             destination_address_prefix = each.value.destinationAddressPrefix
  #             destination_port_range = each.value.destinationPortRange
  #             destination_port_ranges = each.value.destinationPortRanges
  #             access = each.value.access
  #             priority = each.value.priority
  #             direction = each.value.direction
  #         }
  #     }
}

resource "azurerm_network_security_rule" "rules" {
  for_each                    = { for rule in var.securityRules : rule.name => rule }
  network_security_group_name = azurerm_network_security_group.securityGroup.name
  name                        = each.key
  description                 = each.value.description
  resource_group_name         = var.resourceGroupName
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.sourceAddressPrefix
  source_port_range           = each.value.sourcePortRange
  destination_address_prefix  = each.value.destinationAddressPrefix
  destination_port_ranges     = each.value.destinationPortRanges
  access                      = each.value.access
  priority                    = each.value.priority
  direction                   = each.value.direction
}

