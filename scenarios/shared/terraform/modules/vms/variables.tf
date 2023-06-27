variable "osType" {
  default = "Linux"
}

variable "nsgName" {
  default = ""
}

variable "location" {
  default = "northeurope"
}

variable "tags" {
}

variable "vnetName" {
  type = string
}

variable "vnetResourceGroupName" {
}

variable "addressPrefixes" {
}

variable "securityRules" {
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

variable "vmSubnetName" {

}