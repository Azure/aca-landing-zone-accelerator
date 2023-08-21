// ------------------
//    PARAMETERS
// ------------------

variable "location" {
  type = string
}

variable "acaEnvironmentName" {
  type = string
}

variable "logAnalyticsWorkspaceCustomerId" {
  type = string
}

variable "logAnalyticsWorkspaceSharedKey" {
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
