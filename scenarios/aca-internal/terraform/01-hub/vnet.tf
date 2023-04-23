# Virtual Network for Hub

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  dns_servers         = null
  tags                = var.tags
}