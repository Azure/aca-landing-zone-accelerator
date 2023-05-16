output "result" {
  value = {
    fqdn                            = module.frontDoor.frontDoorFqdn
    privateLinkServiceId            = module.frontDoor.privateLinkServiceId
    privateLinkEndpointConnectionId = [for connection in module.frontDoor.privateEndpointConnections : connection.id if connection.description == "frontdoor"]
  }
}