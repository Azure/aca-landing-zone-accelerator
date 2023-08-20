output "spokeResourceGroupName" {
  value = azurerm_resource_group.spokeResourceGroup.name
}

output "spokeResourceGroupId" {
  value = azurerm_resource_group.spokeResourceGroup.id
}

output "spokeVNetId" {
  value = module.vnet.vnetId
}

output "spokeVNetName" {
  value = module.vnet.vnetName
}

output "spokeInfraSubnetId" {
  value = module.vnet.subnets[var.infraSubnetName].id
}

output "spokeInfraSubnetName" {
  value = module.vnet.subnets[var.infraSubnetName].name
}

output "spokePrivateEndpointsSubnetId" {
  value = module.vnet.subnets[var.privateEndpointsSubnetName].id
}

output "spokePrivateEndpointsSubnetName" {
  value = module.vnet.subnets[var.privateEndpointsSubnetName].name
}

output "spokeApplicationGatewaySubnetId" {
  value = var.applicationGatewaySubnetAddressPrefix != "" ? module.vnet.subnets[var.applicationGatewaySubnetName].id : null
}

output "spokeApplicationGatewaySubnetName" {
  value = var.applicationGatewaySubnetAddressPrefix != "" ? module.vnet.subnets[var.applicationGatewaySubnetName].name : null
}

output "logAnalyticsWorkspaceId" {
  value = module.logAnalyticsWorkspace.workspaceId
}
