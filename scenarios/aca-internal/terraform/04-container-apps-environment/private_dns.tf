# private dns zone for ACA

resource "azurerm_private_dns_zone" "private_dns_zone_aca" {
  name                = azurerm_container_app_environment.aca_environment.default_domain
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
}

# todo : attach private dns zone for ACA to hub and to spoke

resource "azurerm_private_dns_zone_virtual_network_link" "link_spoke_dns_aca" {
  name                  = "link-spoke-dns-aca"
  resource_group_name   = data.terraform_remote_state.spoke.outputs.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_aca.name
  virtual_network_id    = data.terraform_remote_state.spoke.outputs.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_hub_dns_aca" {
  name                  = "link-hub-dns-aca"
  resource_group_name   = data.terraform_remote_state.spoke.outputs.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_aca.name
  virtual_network_id    = data.terraform_remote_state.hub.outputs.vnet.id
}