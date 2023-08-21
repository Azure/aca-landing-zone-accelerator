# variable "vnetName" {
#   type = string
# }

variable "resourceGroupName" {
  type = string
}

# variable "addressPrefixes" {}

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
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name        = string
      description = optional(string)
      protocols = list(object({
        type = string
        port = number
      }))
      source_addresses  = list(string)
      destination_fqdns = list(string)
    }))
  }))
}

variable "firewallSubnetName" {
  type = string
}

variable "firewallSubnetAddressPrefix" {
  type = string
}

variable "firewallSubnetMgmtName" {
  type = string
}

variable "firewallSubnetMgmtAddressPrefix" {
  type = string
}

variable "firewallPipMgmtName" {
  type = string
}

variable "vnetName" {
  type = string
}

# variable "firewallSubnetId" {
#   type    = string
# }
