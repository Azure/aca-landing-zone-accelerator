// ------------------
// OUTPUTS
// ------------------

output "nsgId" {
  value = azurerm_network_security_group.securityGroup.id
}

output "nsgName" {
  value = azurerm_network_security_group.securityGroup.name
}