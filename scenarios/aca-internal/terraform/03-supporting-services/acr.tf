resource "random_integer" "deployment" {
  min = 10000
  max = 99999
}

# Deploy Azure Container Registry

module "acr_private" {
  source = "./modules/acr_private"

  acrname             = "acr${random_integer.deployment.result}"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  snet_id             = data.terraform_remote_state.spoke.outputs.snet_pep.id
  private_zone_id     = azurerm_private_dns_zone.dns_zone_acr.id
  tags                = var.tags
}

# Deploy DNS Private Zone for ACR

resource "azurerm_private_dns_zone" "dns_zone_acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_dns_acr_spoke" {
  name                  = "link-dns-acr-spoke"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_acr.name
  resource_group_name   = azurerm_private_dns_zone.dns_zone_acr.resource_group_name
  virtual_network_id    = data.terraform_remote_state.spoke.outputs.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_dns_acr_hub" {
  name                  = "link-dns-acr-hub"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_acr.name
  resource_group_name   = azurerm_private_dns_zone.dns_zone_acr.resource_group_name
  virtual_network_id    = data.terraform_remote_state.hub.outputs.vnet.id
}

# user assigned identity for ACR

resource "azurerm_user_assigned_identity" "identity_acr" {
  name                = "identity-acr"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  tags                = var.tags
}

# RBAC role assignment for ACR

resource "azurerm_role_assignment" "role_assignment_acr" {
  scope                = module.acr_private.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity_acr.principal_id
}
