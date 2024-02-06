variable "routeTableName" {
  default = "routeTableSpoke"
  type    = string
  validation {
    condition     = length(var.routeTableName) >= 2 && length(var.routeTableName) <= 32
    error_message = "Name must be at least 2 characters long and not longer than 32."

  }
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "subnetId" {
  type = string
}

variable "tags" {}

variable "routes" {
  type = list(object({
    name             = string
    addressPrefix    = string
    nextHopType      = string
    nextHopIpAddress = string
  }))
}
