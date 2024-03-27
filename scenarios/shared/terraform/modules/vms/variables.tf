variable "osType" {
  default = "Linux"
}

variable "location" {
  default = "northeurope"
}

variable "tags" {
}

variable "vnetResourceGroupName" {
}

variable "nicName" {
}

variable "vmName" {
}

variable "adminUsername" {
}

variable "adminPassword" {
  default = null
}

variable "resourceGroupName" {
}

variable "size" {
}

variable "subnetId" {

}


variable "authenticationType" {
  type = string
  default = "password"
  validation {
    condition = anytrue([
      var.authenticationType == "password",
      var.authenticationType == "sshPublicKey"
    ])
    error_message = "Authentication type must be password or sshPublicKey."
  }
}

variable "sshAuthorizedKeys" {
  default = null
  type = string
}