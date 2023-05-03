resource "azurerm_virtual_network_peering" "peering" {
  name                         = "${var.localVnetName}-peerTo-${var.remoteVnetName}"
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  allow_forwarded_traffic      = false
  use_remote_gateways          = false

  remote_virtual_network_id = var.remoteVnetId
  virtual_network_name      = var.localVnetName
  resource_group_name       = var.remoteRgName
}

