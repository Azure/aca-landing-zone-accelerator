# vnet peering between hub and spoke

resource "azurerm_virtual_network_peering" "peering_spoke_hub" {
  name                         = "peering-spoke-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.terraform_remote_state.hub.outputs.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "peering_hub_spoke" {
  name                         = "peering-hub-spoke"
  resource_group_name          = data.terraform_remote_state.hub.outputs.vnet.resource_group_name
  virtual_network_name         = data.terraform_remote_state.hub.outputs.vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}