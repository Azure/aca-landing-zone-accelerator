data "azurerm_virtual_network" "remoteVnet" {
  name = var.remoteVnetName
  resource_group_name = var.remoteRgName
}

resource "azurerm_virtual_network_peering" "peering" {
    name = "${var.localVnetName}/peerTo-${var.remoteVnetName}"
    allow_virtual_network_access = true
    allow_gateway_transit = false
    allow_forwarded_traffic = false
    use_remote_gateways = false
    remote_virtual_network_id = data.azurerm_virtual_network.vnet.id
}

