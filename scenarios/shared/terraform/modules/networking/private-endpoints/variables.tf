variable "endpointName" {
  default = ""
  type    = string
  validation {
    condition     = length(var.endpointName) >= 2 && length(var.endpointName) <= 32
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

variable "subnetId" {
  default = ""
  type    = string
}

variable "tags" {
}

variable "privateLinkId" {
  default = ""
  type    = string
}

variable "privateDnsZoneIds" {
  default = []
}

variable "subResourceNames" {

}