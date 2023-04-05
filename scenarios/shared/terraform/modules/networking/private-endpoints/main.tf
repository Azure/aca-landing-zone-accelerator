
resource "azurerm_private_endpoint" "pe" {
    name = var.endpointName
    location = var.location
    resource_group_name = var.resourceGroupName
    subnet_id = var.subnetId
    tags = var.tags

    private_service_connection {
        name = "plc"
        private_connection_resource_id = var.privateLinkId
        is_manual_connection = false

        subresource_names = []
    }

    private_dns_zone_group {
      name = "config1"
      private_dns_zone_ids = var.privateDnsZoneIds
    }
}