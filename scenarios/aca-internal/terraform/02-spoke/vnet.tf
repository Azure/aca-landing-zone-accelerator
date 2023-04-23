# Virtual Network for Spoke

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-spoke"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.1.0.0/16"]
  dns_servers         = null
  tags                = var.tags
}

# subnet infrastructure

resource "azurerm_subnet" "snet_infra" {
  name                                      = "snet-infra"
  resource_group_name                       = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = ["10.1.0.0/23"]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "snet_pep" {
  name                                      = "snet-pep"
  resource_group_name                       = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = ["10.1.2.0/24"]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "snet_agw" {
  name                                      = "snet-agw"
  resource_group_name                       = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = ["10.1.3.0/24"]
  private_endpoint_network_policies_enabled = false
}
