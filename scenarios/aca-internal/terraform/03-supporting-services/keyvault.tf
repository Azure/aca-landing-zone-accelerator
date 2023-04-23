# Deploy Azure Key Vault

module "create_kv" {
  source = "./modules/kv-private"

  name                     = "kv${random_integer.deployment.result}"
  resource_group_name      = data.terraform_remote_state.spoke.outputs.rg.name
  location                 = data.terraform_remote_state.spoke.outputs.rg.location
  tenant_id                = data.azurerm_client_config.current.tenant_id
  snet_id                  = data.terraform_remote_state.spoke.outputs.snet_pep.id
  private_zone_id          = azurerm_private_dns_zone.dns_zone_keyvault.id
}

# Deploy DNS Private Zone for Key Vault

resource "azurerm_private_dns_zone" "dns_zone_keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_spoke_dns_keyvault" {
  name                  = "link-spoke-dns-keyvault"
  resource_group_name   = data.terraform_remote_state.spoke.outputs.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_keyvault.name
  virtual_network_id    = data.terraform_remote_state.spoke.outputs.vnet.id
}

# user assigned identity for key vault

resource "azurerm_user_assigned_identity" "identity_keyvault" {
  name                = "identity-keyvault"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
}

# RBAC role assignment for key vault

resource "azurerm_role_assignment" "role_assignment_keyvault" {
  scope                = module.create_kv.kv_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.identity_keyvault.principal_id
}

data "azurerm_client_config" "current" {}