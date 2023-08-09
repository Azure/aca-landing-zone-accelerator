output "privateLinkServiceId" {
  value = azurerm_private_link_service.privateLinkService.id
}

output "privateEndpointConnections" {
  value = data.azurerm_private_link_service_endpoint_connections.privateEndpointConnections.private_endpoint_connections
}

output "frontDoorFqdn" {
  value = azurerm_cdn_frontdoor_endpoint.frontDoorEndpoint.host_name
}

output "frontDoorId" {
  value = azurerm_cdn_frontdoor_profile.frontDoorProfile.id
}
