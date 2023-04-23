output "hub_vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "hub_vnet" {
  value = {
    id = azurerm_virtual_network.vnet.id
    name = azurerm_virtual_network.vnet.name
    resource_group_name = azurerm_resource_group.rg.name
  }
}

output "hub_rg_location" {
  value = azurerm_resource_group.rg.location
}

output "hub_rg_name" {
  value = azurerm_resource_group.rg.name
}