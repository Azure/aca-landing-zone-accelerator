resource "azurerm_route_table" "rt" {
  name                          = var.routeTableName
  resource_group_name           = var.resourceGroupName
  location                      = var.location
  disable_bgp_route_propagation = true
  tags                          = var.tags
}

resource "azurerm_route" "routeToFirewall" {
  name                   = "defaultEgressLockdown"
  resource_group_name    = azurerm_route_table.rt.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance" # "VirtualNetworkGateway"
  next_hop_in_ip_address = var.firewallPrivateIp
}

resource "azurerm_subnet_route_table_association" "associationRtSubnetInfra" {
  subnet_id      = var.subnetId
  route_table_id = azurerm_route_table.rt.id
}