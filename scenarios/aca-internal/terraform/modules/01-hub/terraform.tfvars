
// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment                  = "dev"
tags                         = {}
hubResourceGroupName         = ""
vnetAddressPrefixes          = ["10.0.0.0/24"]
enableBastion                = true
bastionSubnetAddressPrefixes = ["10.0.0.128/26"]
firewallSkuTier              = "Basic" # "Standard"

# applicationRuleCollections = [
#   {
#     name     = "allow-aca-rules"
#     priority = 110
#     action   = "Allow"

#     rule {
#       name = "allow-aca-controlplane"
#       protocols {
#         type = "Http"
#         port = 80
#       }
#       protocols {
#         type = "Https"
#         port = 443
#       }
#       source_addresses  = ["*"]
#       destination_fqdns = [
#         "mcr.microsoft.com",
#         "*.data.mcr.microsoft.com",
#         # "*.blob.${environment().suffixes.storage}" //NOTE: If you use ACR the endpoint must be added as well.
#       ]
#     }
#   }
# ]