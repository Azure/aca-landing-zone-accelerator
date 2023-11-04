module "nsg" {
  source            = "../networking/nsg"
  nsgName           = var.bastionNsgName
  location          = var.location
  resourceGroupName = var.vnetResourceGroupName
  securityRules     = var.securityRules.default
  tags              = var.tags
}

resource "azurerm_subnet" "bastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.vnetResourceGroupName
  virtual_network_name = var.vnetName
  address_prefixes     = var.addressPrefixes
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastionSubnet.id
  network_security_group_id = module.nsg.nsgId
}

resource "azurerm_public_ip" "bastionPip" {
  name                = var.bastionPipName
  location            = var.location
  resource_group_name = var.vnetResourceGroupName

  sku      = "Standard"
  sku_tier = "Regional"

  allocation_method = "Static"

  tags = var.tags
}

resource "azurerm_bastion_host" "bastionHost" {
  name                = var.bastionHostName
  location            = var.location
  resource_group_name = var.vnetResourceGroupName
  ip_configuration {
    name                 = "ipconf"
    subnet_id            = azurerm_subnet.bastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastionPip.id
  }
}
