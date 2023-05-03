// ------------------
// OUTPUTS
// ------------------

output "acrId" {
  value = azurerm_container_registry.acr.id
}

output "acrName" {
  value = azurerm_container_registry.acr.name
}

output "containerRegistryUserAssignedIdentityId" {
  value = azurerm_user_assigned_identity.containerRegistryUserAssignedIdentity.id
}