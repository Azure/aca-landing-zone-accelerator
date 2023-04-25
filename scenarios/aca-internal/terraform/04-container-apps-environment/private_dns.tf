# private dns zone for ACA

resource "azurerm_private_dns_zone" "private_dns_zone_aca" {
  name                = azurerm_container_app_environment.aca_environment.default_domain
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
}

# A record for ACA

resource "azurerm_private_dns_a_record" "private_dns_a_record_aca" {
  name                = "*"
  resource_group_name = azurerm_private_dns_zone.private_dns_zone_aca.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns_zone_aca.name
  ttl                 = 60
  records             = [azurerm_container_app_environment.aca_environment.static_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_spoke_dns_aca" {
  name                  = "link-spoke-dns-aca"
  resource_group_name   = data.terraform_remote_state.spoke.outputs.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_aca.name
  virtual_network_id    = data.terraform_remote_state.spoke.outputs.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_hub_dns_aca" {
  name                  = "link-hub-dns-aca"
  resource_group_name   = data.terraform_remote_state.spoke.outputs.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_aca.name
  virtual_network_id    = data.terraform_remote_state.hub.outputs.vnet.id
  registration_enabled  = false
}