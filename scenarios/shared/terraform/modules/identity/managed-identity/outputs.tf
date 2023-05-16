output "managedIdentityName" {
  value = azurerm_user_assigned_identity.managedIdentity.name
}

output "managedIdentityId" {
  value = azurerm_user_assigned_identity.managedIdentity.id
}

output "managedIdentityPrincipalId" {
  value = azurerm_user_assigned_identity.managedIdentity.principal_id
}

output "managedIdentityTenantId" {
  value = azurerm_user_assigned_identity.managedIdentity.tenant_id
}

output "managedIdentityClientId" {
  value = azurerm_user_assigned_identity.managedIdentity.client_id
}