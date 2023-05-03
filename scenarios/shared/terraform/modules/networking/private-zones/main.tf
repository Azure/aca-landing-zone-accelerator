resource "azurerm_private_dns_zone" "privDnsZone" {
  name                = var.zoneName
  resource_group_name = var.resourceGroupName
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each              = { for vnet in var.vnetLinks : vnet.name => vnet }
  name                  = "${each.key}-link"
  resource_group_name   = azurerm_private_dns_zone.privDnsZone.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.privDnsZone.name
  virtual_network_id    = each.value.vnetId
  registration_enabled  = each.value.registrationEnabled

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "aRecords" {
  for_each            = { for record in var.records : record.name => record }
  zone_name           = azurerm_private_dns_zone.privDnsZone.name
  resource_group_name = var.resourceGroupName

  name    = each.key
  ttl     = 60
  records = each.value.ipv4Address

  tags = var.tags

}