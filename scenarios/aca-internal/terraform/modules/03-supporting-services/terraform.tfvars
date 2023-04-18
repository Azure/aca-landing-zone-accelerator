// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment                         = "dev"
location                            = "eastus"
resourceGroupName                   = "supporting-services"
aRecords                            = []
hubVnetId                           = "/subscriptions/abd9af80-a790-4ce5-aaf0-f8f61ad4dacb/resourceGroups/rg-lzaaca-hub-dev-eus/providers/Microsoft.Network/virtualNetworks/vnet-dev-eus-hub"
spokeVnetId                         = "/subscriptions/abd9af80-a790-4ce5-aaf0-f8f61ad4dacb/resourceGroups/rg-lzaaca-spoke-dev-eus/providers/Microsoft.Network/virtualNetworks/vnet-lzaaca-dev-eus-spoke"
spokePrivateEndpointSubnetId        = "/subscriptions/abd9af80-a790-4ce5-aaf0-f8f61ad4dacb/resourceGroups/rg-lzaaca-spoke-dev-eus/providers/Microsoft.Network/virtualNetworks/vnet-lzaaca-dev-eus-spoke/subnets/snet-pep"
containerRegistryPullRoleAssignment = "acrRoleAssignment"
tags                                = {}