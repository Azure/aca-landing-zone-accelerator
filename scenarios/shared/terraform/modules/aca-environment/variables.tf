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

variable "workloadProfiles" {
  description = "Optional, the workload profiles required by the end user. The default is 'Consumption', and is automatically added whether workload profiles are specified or not."
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = number
    maximum_count         = number
  }))
}