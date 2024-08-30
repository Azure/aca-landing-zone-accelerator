resource "azurerm_route_table" "rt" {
  name                          = var.routeTableName
  resource_group_name           = var.resourceGroupName
  location                      = var.location
  bgp_route_propagation_enabled = false
  tags                          = var.tags
}

resource "azurerm_route" "routeToFirewall" {
  for_each               = { for route in var.routes : route.name => route }
  name                   = each.value.name
  resource_group_name    = azurerm_route_table.rt.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = each.value.addressPrefix
  next_hop_type          = each.value.nextHopType
  next_hop_in_ip_address = each.value.nextHopIpAddress
}

resource "azurerm_subnet_route_table_association" "associationRtSubnetInfra" {
  subnet_id      = var.subnetId
  route_table_id = azurerm_route_table.rt.id
}
