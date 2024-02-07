resource "azurerm_virtual_network" "vnet" {
  name                = var.networkName
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = var.addressSpace
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.key
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  address_prefixes     = each.value.addressPrefixes

  dynamic "delegation" {
    for_each = lookup(var.subnetDelegations, each.key, {})

    content {
      name = delegation.key

      service_delegation {
        name = delegation.value.service_name
        actions = delegation.value.service_actions
      }
    }
  }
}
