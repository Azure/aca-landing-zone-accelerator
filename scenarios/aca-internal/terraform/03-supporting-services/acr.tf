resource "random_integer" "deployment" {
  min = 10000
  max = 99999
}

# Deploy Azure Container Registry

module "create_acr" {
  source = "./modules/acr-private"

  acrname             = "acr${random_integer.deployment.result}"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  snet_id             = data.terraform_remote_state.spoke.outputs.snet_pep.id
  private_zone_id     = azurerm_private_dns_zone.dns_zone_acr.id
}

# Deploy DNS Private Zone for ACR

resource "azurerm_private_dns_zone" "dns_zone_acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_spoke_dns_acr" {
  name                  = "link-spoke-dns-acr"
  resource_group_name   = data.terraform_remote_state.spoke.outputs.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_acr.name
  virtual_network_id    = data.terraform_remote_state.spoke.outputs.vnet.id
}

# user assigned identity for ACR

resource "azurerm_user_assigned_identity" "identity_acr" {
  name                = "identity-acr"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
}

# RBAC role assignment for ACR

resource "azurerm_role_assignment" "role_assignment_acr" {
  scope                = module.create_acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity_acr.principal_id
}