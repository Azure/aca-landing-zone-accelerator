// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment = "dev"
tags        = {}

hubVnetAddressPrefixes                     = ["10.0.0.0/24"]
gatewaySubnetAddressPrefix                 = "10.0.0.0/27"
azureFirewallSubnetAddressPrefix           = "10.0.0.64/26"
bastionSubnetAddressPrefixes               = ["10.0.0.128/26"]
azureFirewallSubnetManagementAddressPrefix = "10.0.0.192/26"

spokeVnetAddressPrefixes              = ["10.1.0.0/22"]
vmJumpBoxSubnetAddressPrefix          = "10.1.2.32/27"
infraSubnetAddressPrefix              = "10.1.0.0/27"
privateEndpointsSubnetAddressPrefix   = "10.1.2.0/27"
applicationGatewaySubnetAddressPrefix = "10.1.3.0/24"

enableBastion            = true
vmSize                   = "Standard_B2ms" # "Standard_B2als_v2" not supported in north europe
vmAdminUsername          = "vmadmin"
vmAdminPassword          = "@Aa123456789" # change this to a strong password
vmLinuxSshAuthorizedKeys = "<Your SSH public key>"
vmJumpboxOSType          = "Linux"
infraSubnetName          = "snet-infra"

deployHelloWorldSample              = true
clientIP                            = "<Your computer's IP address>"
supportingResourceGroupName         = "supporting-services"
aRecords                            = []
containerRegistryPullRoleAssignment = "acrRoleAssignment"
keyVaultPullRoleAssignment          = "keyVaultRoleAssignment"
appInsightsName                     = "appInsightsAca"
helloWorldContainerAppName          = "ca-hello-world"
appGatewayCertificateKeyName        = "agwcert"
appGatewayFQDN                      = "acahello.demoapp.com"

workloadProfiles = [{
  name                  = "general-purpose"
  workload_profile_type = "D4"
  minimum_count         = 1
  maximum_count         = 3
}]
