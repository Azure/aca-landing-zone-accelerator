output "key_vault_id" {
  value = module.create_kv.kv_id
}

output "container_registry_id" {
  value = module.create_acr.acr_id
}