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
}

variable "hubResourceGroupName" {}

variable "tags" {}

variable "vnetAddressPrefixes" {}

variable "enableBastion" {
  default = true
  type    = bool
}

variable "bastionSubnetAddressPrefixes" {}

variable "securityRules" {
  default = []
}

variable "gatewaySubnetName" {
  default = "GatewaySubnet"
  type    = string
}
  
variable "gatewaySubnetAddressPrefix" {}

variable "azureFirewallSubnetName" {
  default = "AzureFirewallSubnet"
  type = string
}

variable "azureFirewallSubnetAddressPrefix" {
  type = string
}

variable "firewallSkuTier" {
  type    = string
  default = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewallSkuTier)
    error_message = "firewallSkuTier must be Basic, Standard or Premium"
  }
}

variable "azureFirewallSubnetMgmtName" {
  default = "AzureFirewallManagementSubnet"
  type = string
}

variable "azureFirewallSubnetMgmtAddressPrefix" {
  type = string
}

variable "applicationRuleCollections" {
  default = []
  # type = 
}