output "keyvault" {
  value = {
    id = module.create_kv.kv_id
  }
}

output "acr" {
  value = {
    id = module.create_acr.acr_id
  }
}