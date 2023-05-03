resource "azurerm_user_assigned_identity" "managedIdentity" {
  name                = var.managedIdentityName
  resource_group_name = var.resourceGroupName
  location            = var.location
  tags                = var.tags
}