variable "vnetName" {
  type = string
}

variable "vnetResourceGroupName" {
  type = string
}

variable "addressPrefixes" {}

variable "firewallPipName" {}

variable "tags" {}

variable "firewallName" {}

variable "location" {}

variable "firewallSkuTier" {
  type    = string
  default = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewallSkuTier)
    error_message = "firewallSkuTier must be Basic, Standard or Premium"
  }
}

variable "applicationRuleCollections" {
  default = []
  # type = 
}

# variable "firewallSubnetId" {
#   type    = string
# }