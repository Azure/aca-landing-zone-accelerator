// ------------------
// OUTPUTS
// ------------------

output "vnetId" {
  value = azurerm_virtual_network.vnet.id
}

output "vnetName" {
  value = azurerm_virtual_network.vnet.name
}

output "subnetIds" {
  value = tomap({ for subnet in azurerm_subnet.subnets : subnet.name => subnet.id })
}
