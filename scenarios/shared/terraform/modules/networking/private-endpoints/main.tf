
resource "azurerm_private_endpoint" "pe" {
  name                = var.endpointName
  location            = var.location
  resource_group_name = var.resourceGroupName
  subnet_id           = var.subnetId
  tags                = var.tags

  private_service_connection {
    name                           = "plc"
    is_manual_connection           = false
    private_connection_resource_id = var.privateLinkId
    subresource_names              = var.subResourceNames
  }

  private_dns_zone_group {
    name                 = "config1"
    private_dns_zone_ids = var.privateDnsZoneIds
  }
}