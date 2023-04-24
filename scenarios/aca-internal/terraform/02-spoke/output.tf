output "rg" {
  value = {
    name     = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
  }
}

output "vnet" {
  value = {
    id   = azurerm_virtual_network.vnet.id
    name = azurerm_virtual_network.vnet.name
  }
}

output snet_pep {
  value = {
    id   = azurerm_subnet.snet_pep.id
  }
}

output snet_infra {
  value = {
    id   = azurerm_subnet.snet_infra.id
  }
}