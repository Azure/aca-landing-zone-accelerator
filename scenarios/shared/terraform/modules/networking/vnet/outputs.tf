// ------------------
// OUTPUTS
// ------------------

output "vnetId" {
  value = azurerm_virtual_network.vnet.id
}

output "vnetName" {
  value = azurerm_virtual_network.vnet.name
}

output "subnets" { # todo: delete
  value = azurerm_subnet.subnets
}

output "firewallSubnetId" {
  value = azurerm_subnet.subnets # ["AzureFirewallSubnet"] # todo
  # value = "hello"
}