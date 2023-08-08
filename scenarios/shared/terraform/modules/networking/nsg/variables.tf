variable "nsgName" {
  default = ""
  type    = string
}

variable "resourceGroupName" {
  default = ""
  type    = string
}

variable "location" {
  default = ""
  type    = string
}

variable "tags" {}

variable "securityRules" {
  default = []
}