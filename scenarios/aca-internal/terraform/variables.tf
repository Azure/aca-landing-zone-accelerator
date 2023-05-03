variable "workloadName" {
  type = string
  validation {
    condition     = length(var.workloadName) >= 2 && length(var.workloadName) <= 10
    error_message = "Name must be greater at least 2 characters and not greater than 10."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = length(var.environment) <= 8
    error_message = "Environment name can't be greater than 8 characters long."
  }
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "hubResourceGroupName" {
  default = ""
}

variable "spokeResourceGroupName" {
  default = ""
}

variable "tags" {}

variable "hubVnetAddressPrefixes" {

}

variable "enableBastion" {
  default = true
  type    = bool
}

variable "bastionSubnetAddressPrefixes" {}

variable "vmSize" {}

variable "vmAdminUsername" {
  default = "vmadmin"
}

variable "vmAdminPassword" {
  sensitive = true
  default = null
}

variable "vmLinuxSshAuthorizedKeys" {}

variable "vmJumpboxOSType" {
  default = "Linux"
  validation {
    condition = anytrue([
      var.vmJumpboxOSType == "Linux",
      var.vmJumpboxOSType == "Windows"
    ])
    error_message = "OS Type must be Linux or Windows."
  }
}

variable "vmSubnetName" {
  default = "snet-jumpbox"
  type    = string
}

variable "ddosProtectionPlanId" {
  default = null
  type    = string
}

variable "securityRules" {
  default = []
}

variable "vmJumpBoxSubnetAddressPrefix" {

}

variable "spokeVnetAddressPrefixes" {
  default = ""

}

variable "infraSubnetAddressPrefix" {
  default = ""

}

variable "infraSubnetName" {
  default = "snet-infra"

}

variable "privateEndpointsSubnetName" {
  default = "snet-pep"
}

variable "privateEndpointsSubnetAddressPrefix" {
  default = ""

}

variable "applicationGatewaySubnetName" {
  default = "snet-agw"
}

variable "applicationGatewaySubnetAddressPrefix" {
  default = ""
}

variable "supportingResourceGroupName" {

}

variable "aRecords" {

}

variable "containerRegistryPullRoleAssignment" {

}

variable "keyVaultPullRoleAssignment" {

}

variable "appGatewayCertificatePath" {
  default = "configuration/acahello.demoapp.com.pfx"
}

variable "appGatewayCertificateKeyName" {

}

variable "appGatewayFQDN" {

}

variable "appGatewayPrimaryBackendEndFQDN" {

}

variable "appInsightsName" {

}

variable "helloWorldContainerAppName" {

}

variable "enableTelemetry" {
  type    = bool
  default = true
}