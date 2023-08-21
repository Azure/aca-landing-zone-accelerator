resource "azurerm_route_table" "routeTable" {
  name                          = var.routeTableName
  location                      = var.location
  resource_group_name           = var.resourceGroupName
  disable_bgp_route_propagation = true
  tags                          = var.tags
}

resource "azurerm_route" "route" {
  for_each               = { for route in var.routes : route.name => route }
  name                   = each.key
  route_table_name       = azurerm_route_table.routeTable.name
  resource_group_name    = var.resourceGroupName
  address_prefix         = each.value.addressPrefix
  next_hop_type          = each.value.nextHopType
  next_hop_in_ip_address = each.value.nextHopInIpAddress
}
