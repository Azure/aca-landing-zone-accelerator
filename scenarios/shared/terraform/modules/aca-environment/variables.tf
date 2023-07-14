// ------------------
//    PARAMETERS
// ------------------

variable "location" {
  type    = string
  default = "northeurope"
}

variable "environmentName" {
  type = string
}

variable "logAnalyticsWorkspaceId" {
  type = string
}

variable "subnetId" {
  type = string
}

variable "resourceGroupName" {}

