// ------------------
// OUTPUTS
// ------------------

output "acrId" {
    value = azurerm_container_registry.acr.id
}

output "acrName" {
    value = azurerm_container_registry.acr.name
}