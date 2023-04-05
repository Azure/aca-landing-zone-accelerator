// ------------------
// OUTPUTS
// ------------------

output "hubVnetId" {
  description = "The resource ID of hub virtual network."
  value       = module.vnet.vnetId
}

output "resourceGroupName" {
  description = "The name of the Hub resource group."
  value       = azurerm_resource_group.hubResourceGroup.name
}