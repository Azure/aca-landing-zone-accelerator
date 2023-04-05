
// The name of the workloard that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
workloadName = "lzaaca"
//The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
environment                  = "dev"
tags                         = {}
hubResourceGroupName         = ""
vnetAddressPrefixes          = ["10.0.0.0/16"]
enableBastion                = true
bastionSubnetAddressPrefixes = ["10.0.2.0/27"]
vmSize                       = "Standard_B2ms"
vmAdminUsername              = "azureuser"
vmAdminPassword              = "Password123"
vmLinuxSshAuthorizedKeys     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpNpoh248rsraL3uejAwKlla+pHaDLbp4DM7bKFoc3Rt1DeXPs0XTutJcNtq4iRq+ooRQ1T7WaK42MfQQxt3qkXwjyv8lPJ4v7aElWkAbxZIRYVYmQVxxwfw+zyB1rFdaCQD/kISg/zXxCWw+gdds4rEy7eq23/bXFM0l7pNvbAULIB6ZY7MRpC304lIAJusuZC59iwvjT3dWsDNWifA1SJtgr39yaxB9Fb01UdacwJNuvfGC35GNYH0VJ56c+iCFeAnMXIT00cYuHf0FCRTP0WvTKl+PQmeD1pwxefdFvKCVpidU2hOARb4ooapT0SDM1SODqjaZ/qwWP18y/qQ/v imported-openssh-key"
vmJumpboxOSType              = "Linux"
vmJumpBoxSubnetAddressPrefix = "10.0.3.0/24"