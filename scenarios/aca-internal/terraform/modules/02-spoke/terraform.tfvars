// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment                           = "dev"
tags                                  = {}
spokeResourceGroupName                = ""
vnetAddressPrefixes                   = ["10.1.0.0/22"]
infraSubnetAddressPrefix              = "10.1.0.0/23"
privateEndpointsSubnetAddressPrefix   = "10.1.2.0/27"
applicationGatewaySubnetAddressPrefix = "10.1.3.0/24"
vmJumpBoxSubnetAddressPrefix          = "10.1.2.32/27"
infraSubnetName                       = "snet-infra"
hubVnetId                             = "<Hub VNET ID>"
vmSize                                = "Standard_B2ms"
vmAdminUsername                       = "azureuser"
vmAdminPassword                       = ""
vmLinuxSshAuthorizedKeys              = ""
vmJumpboxOSType                       = "Linux"