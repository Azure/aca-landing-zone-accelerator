output "vnet" {
  value = {
    id                  = azurerm_virtual_network.vnet.id
    name                = azurerm_virtual_network.vnet.name
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
  }
}
