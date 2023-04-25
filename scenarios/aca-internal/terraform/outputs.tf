// Hub
output "hubVnetId" {
  value = module.hub.hubVnetId
}

output "hubResourceGroupName" {
  value = module.hub.resourceGroupName
}

// Spoke
output "spokeVnetId" {
  value = module.spoke.spokeVNetId
}

output "spokeResourceGroupName" {
  value = module.spoke.spokeResourceGroupName
}

output "spokeVnetName" {
  value = module.spoke.spokeVNetName
}

output "spokeInfraSubnetId" {
  value = module.spoke.spokeInfraSubnetId
}

output "spokeInfraSubnetName" {
  value = module.spoke.spokeInfraSubnetName
}

output "spokePrivateEndpointsSubnetId" {
  value = module.spoke.spokePrivateEndpointsSubnetId
}

output "spokePrivateEndpointsSubnetName" {
  value = module.spoke.spokePrivateEndpointsSubnetName
}

output "spokeApplicationGatewaySubnetId" {
  value = module.spoke.spokeApplicationGatewaySubnetId
}

output "spokeApplicationGatewaySubnetName" {
  value = module.spoke.spokeApplicationGatewaySubnetName
}

// Supporting Services
output "containerRegistryId" {
  value = module.supportingServices.containerRegistryId
}

output "containerRegistryName" {
  value = module.supportingServices.containerRegistryName
}

output "containerRegistryUserAssignedIdentityId" {
  value = module.supportingServices.containerRegistryUserAssignedIdentityId
}

output "keyVaultId" {
  value = module.supportingServices.keyVaultId
}

output "keyVaultName" {
  value = module.supportingServices.keyVaultName
}

output "keyVaultUserAssignedIdentityId" {
  value = module.supportingServices.keyVaultUserAssignedIdentityId
}

// Container Apps Environment
output "containerAppsEnvironmentId" {
  value = module.containerAppsEnvironment.containerAppsEnvironmentId
}

output "containerAppsEnvironmentName" {
  value = module.containerAppsEnvironment.containerAppsEnvironmentName
}

output "logAnalyticsWorkspaceId" {
    value = module.containerAppsEnvironment.logAnalyticsWorkspaceId
}

output "logAnalyticsWorkspaceCustomerId" {
  value = module.containerAppsEnvironment.logAnalyticsWorkspaceId
}