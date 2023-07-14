output "containerRegistryId" {
  value = module.containerRegistry.acrId
}

output "containerRegistryName" {
  value = module.containerRegistry.acrName
}

output "containerRegistryUserAssignedIdentityId" {
  value = module.containerRegistry.containerRegistryUserAssignedIdentityId
}

output "keyVaultId" {
  value = module.keyVault.keyVaultId
}

output "keyVaultName" {
  value = module.keyVault.keyVaultName
}