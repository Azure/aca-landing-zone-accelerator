output "keyvault" {
  value = {
    id = module.keyvault_private.keyvault_id
  }
}

output "acr" {
  value = {
    id = module.acr_private.acr_id
  }
}