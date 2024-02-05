output "applicationGatewayPublicIp" {
  value = module.applicationGateway.applicationGatewayPublicIp
}

output "hubResourceGroupName" {
  value = module.hub.hubResourceGroupName
}

output "spokeResourceGroupName" {
  value = module.spoke.spokeResourceGroupName
}