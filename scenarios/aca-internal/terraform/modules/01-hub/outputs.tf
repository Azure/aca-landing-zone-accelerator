// ------------------
// OUTPUTS
// ------------------

output "hubVnetId" {
  description = "The resource ID of hub virtual network."
  value       = module.vnet.vnetId
}

output "hubVnetName" {
  value = module.vnet.vnetName
}

output "hubResourceGroupName" {
  description = "The name of the Hub resource group."
  value       = azurerm_resource_group.hubResourceGroup.name
}

output "firewallPrivateIp" {
  description = "The private IP address of the firewall."
  value       = module.firewall.firewallPrivateIp
}