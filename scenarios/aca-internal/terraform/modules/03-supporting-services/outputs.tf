output "containerRegistryId" {
  value = module.containerRegistry.acrId
}

output "containerRegistryName" {
  value = module.containerRegistry.acrName
}

output "containerRegistryUserAssignedIdentityId" {
  value = module.containerRegistry
}

output "keyVaultId" {
  value = module.keyVault.keyVaultId
}

output "keyVaultName" {
  value = module.keyVault.keyVaultName
}

output "keyVaultUserAssignedIdentityId" {
value = module.keyVault.keyVaultUserAssignedIdentityId
}