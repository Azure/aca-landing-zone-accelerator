variable "networkName" {
  type    = string
  validation {
    condition     = length(var.networkName) >= 2 && length(var.networkName) <= 32
    error_message = "Name must be at least 2 characters long and not longer than 32."

  }
}

variable "location" {
  type    = string
}

variable "resourceGroupName" {
  type    = string
}

variable "addressSpace" {
}

variable "tags" {
}

variable "subnets" {
  type = list(object({
    name            = string,
    addressPrefixes = string,
    service_delegation = optional(list(object({
      name    = string,
      actions = list(string)
    })))
  }))
}
