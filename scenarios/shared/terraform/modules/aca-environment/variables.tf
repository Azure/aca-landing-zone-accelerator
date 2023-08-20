// ------------------
//    PARAMETERS
// ------------------

variable "location" {
  type    = string
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

variable "resourceGroupName" {
  type = string
}

variable "resourceGroupId" {
  type = string
}

variable "tags" {
  type = map(string)
}
