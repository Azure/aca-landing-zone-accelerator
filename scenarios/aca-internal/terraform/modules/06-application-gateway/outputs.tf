output "applicationGatewayPublicIp" {
  value = azurerm_public_ip.appGatewayPip.ip_address
}

