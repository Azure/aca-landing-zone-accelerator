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

variable "hubVnetId" {
  default = ""
}

variable "spokeResourceGroupName" {
  default = ""

}

variable "tags" {

}

variable "vnetAddressPrefixes" {
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

variable "securityRules" {
  default = []
}