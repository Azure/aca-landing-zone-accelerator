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

output "firewall_private_ip_address" {
  value = module.firewall.firewall_private_ip_address
}

output "subnets" {
  value = module.vnet.subnets
}

# output "firewallSubnetId" {
#   description = "The resource ID of the firewall subnet."
#   value       = module.vnet.firewallSubnetId
# }
