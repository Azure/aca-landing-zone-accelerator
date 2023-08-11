output "applicationGatewayId" {
  value = azurerm_application_gateway.appGateway.id
}

output "applicationGatewayPublicIp" {
  value = azurerm_public_ip.appGatewayPip.ip_address
}