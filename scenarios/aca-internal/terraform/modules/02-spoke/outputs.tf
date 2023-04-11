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
  
}

output "spokeInfraSubnetName" {

}

output "spokePrivateEndpointsSubnetId" {

}

output "spokePrivateEndpointsSubnetName" {

}

output "spokeApplicationGatewaySubnetId" {

}

output "spokeApplicationGatewaySubnetName" {
    
}