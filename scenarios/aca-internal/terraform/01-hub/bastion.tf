# Bastion - Module creates additional subnet (without NSG), public IP and Bastion

module "bastion" {
  source = "./modules/bastion"

  subnet_cidr          = "10.0.2.0/27"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
}