variable "managedIdentityName" {
  default = ""
  type    = string
  validation {
    condition     = length(var.managedIdentityName) >= 3 && length(var.managedIdentityName) <= 128
    error_message = "Name must be greater than 3 characters and not longer than 128 characters."
  }
}

variable "resourceGroupName" {
  type = string
}

variable "location" {
  default = "northeurope"
  type    = string
}

variable "tags" {

}
