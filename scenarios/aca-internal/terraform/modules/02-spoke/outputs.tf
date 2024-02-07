output "spokeResourceGroupName" {
  value = azurerm_resource_group.spokeResourceGroup.name
}

output "spokeVNetId" {
  value = module.vnet.vnetId
}

output "spokeVNetName" {
  value = module.vnet.vnetName
}

output "spokeInfraSubnetId" {
  value = data.azurerm_subnet.infraSubnet.id
}

output "spokeInfraSubnetName" {
  value = data.azurerm_subnet.infraSubnet.name
}

output "spokePrivateEndpointsSubnetId" {
  value = data.azurerm_subnet.privateEndpointsSubnet.id
}

output "spokePrivateEndpointsSubnetName" {
  value = data.azurerm_subnet.privateEndpointsSubnet.name
}

output "spokeApplicationGatewaySubnetId" {
  value = var.applicationGatewaySubnetAddressPrefix != "" ? data.azurerm_subnet.appGatewaySubnet[0].id : null
}

output "spokeApplicationGatewaySubnetName" {
  value = var.applicationGatewaySubnetAddressPrefix != "" ? data.azurerm_subnet.appGatewaySubnet[0].name : null
}

output "logAnalyticsWorkspaceId" {
  value = module.logAnalyticsWorkspace.workspaceId
}