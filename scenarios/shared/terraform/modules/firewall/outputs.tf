output "firewallId" {
  value = azurerm_firewall.firewall.id
}

output "firewallPrivateIp" {
  value = azurerm_firewall.firewall.ip_configuration.0.private_ip_address
}
