## Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = var.networkName
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = var.addressSpace


  # var.ddosProtectionPlanId != "" ? ddos_protection_plan  {
  #     enable = var.ddosProtectionPlanId != ""? true: false
  #     id = var.ddosProtectionPlanId != ""? var.ddosProtectionPlanId: null
  # }


  tags = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.key
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name

  address_prefixes = each.value.addressPrefixes
}