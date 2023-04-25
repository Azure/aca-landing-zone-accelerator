resource "azurerm_subnet" "snet_bastionhost" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_public_ip" "pip_bastion_host" {
  name                = "pip-bastion-host"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "bastion-host"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.snet_bastionhost.id
    public_ip_address_id = azurerm_public_ip.pip_bastion_host.id
  }
}
