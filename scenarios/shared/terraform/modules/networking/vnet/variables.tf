variable "networkName" {
  default = ""
  type    = string
  validation {
    condition     = length(var.networkName) >= 2 && length(var.networkName) <= 32
    error_message = "Name must be at least 2 characters long and not longer than 32."

  }
}

variable "location" {
  default = "northeurope"
  type    = string
}

variable "resourceGroupName" {
  default = ""
  type    = string
}

variable "addressSpace" {
}

variable "tags" {
}

variable "ddosProtectionPlanId" {
  default = ""
  type    = string
}

variable "subnets" {
}