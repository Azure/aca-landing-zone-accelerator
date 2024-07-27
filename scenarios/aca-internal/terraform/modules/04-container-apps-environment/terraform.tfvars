// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment            = "dev"
location               = "<Your region to deploy resources>"
spokeResourceGroupName = "<Your hub resource group name>"
appInsightsName        = "appInsightsAca"
hubVnetId              = "<Your Hub VNet resource ID>"
spokeVnetId            = "<Your Spoke VNet resource ID>"
spokeInfraSubnetId     = "<Your Infra Subnet resource ID>"
tags                   = {}
hubResourceGroupName   = "<Your Hub Resource Group Name>"
logAnalyticsWorkspaceId = "<Your Log Analytics Workspace resource ID>"
vnetLinks = []
