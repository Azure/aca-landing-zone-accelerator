# Deploy Azure Key Vault

module "keyvault_private" {
  source = "./modules/keyvault_private"

  name                = "kv${random_integer.deployment.result}"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  snet_id             = data.terraform_remote_state.spoke.outputs.snet_pep.id
  private_zone_id     = azurerm_private_dns_zone.dns_zone_keyvault.id
  tags                = var.tags
}

# Deploy DNS Private Zone for Key Vault

resource "azurerm_private_dns_zone" "dns_zone_keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_dns_keyvault_spoke" {
  name                  = "link-dns-keyvault-spoke"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_keyvault.name
  resource_group_name   = azurerm_private_dns_zone.dns_zone_keyvault.resource_group_name
  virtual_network_id    = data.terraform_remote_state.spoke.outputs.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_dns_keyvault_hub" {
  name                  = "link-dns-keyvault-hub"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_keyvault.name
  resource_group_name   = azurerm_private_dns_zone.dns_zone_keyvault.resource_group_name
  virtual_network_id    = data.terraform_remote_state.hub.outputs.vnet.id
}

# user assigned identity for key vault

resource "azurerm_user_assigned_identity" "identity_keyvault" {
  name                = "identity-keyvault"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  tags                = var.tags
}

# RBAC role assignment for key vault

resource "azurerm_role_assignment" "role_assignment_keyvault" {
  scope                = module.keyvault_private.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.identity_keyvault.principal_id
}

data "azurerm_client_config" "current" {}
