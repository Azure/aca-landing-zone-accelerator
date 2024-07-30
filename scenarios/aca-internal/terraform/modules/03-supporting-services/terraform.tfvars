// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment                         = "dev"
supportingResourceGroupName         = "supporting-services"
aRecords                            = []
hubVnetId                           = "<Your hub vnet resource ID>"
spokeVnetId                         = "<Your spoke vnet resource ID>"
spokePrivateEndpointSubnetId        = "<Your spoke private endpoint subnet resource ID>"
containerRegistryPullRoleAssignment = "acrRoleAssignment"
keyVaultPullRoleAssignment          = "keyVaultRoleAssignment"
clientIP                            = "<Your computer's IP address>"
tags                                = {}
hubResourceGroupName                = "<Your hub resource group name>"
spokeResourceGroupName              = "<Your spoke resource group name>"
location                            = "<Your resource location>"
logAnalyticsWorkspaceId             = "<Your Log Analytics Workspace resource ID>"
vnetLinks                           = []
