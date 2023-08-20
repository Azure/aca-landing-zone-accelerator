// ------------------
// OUTPUTS
// ------------------

output "vnetId" {
  value = azurerm_virtual_network.vnet.id
}

output "vnetName" {
  value = azurerm_virtual_network.vnet.name
}

output "subnets" {
  value = tomap({ for subnet in azurerm_subnet.subnets :
    subnet.name => {
      name = subnet.name
      id   = subnet.id
    }
  })
}