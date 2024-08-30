variable "subscription_id" {
  sensitive = true
  type = string
}

variable "tags" {}

variable "helloWorldContainerAppName" {
  type    = string
  default = "ca-simple-hello"
  validation {
    condition     = length(var.helloWorldContainerAppName) >= 2 && length(var.helloWorldContainerAppName) <= 32
    error_message = "Name must be greater at least 2 characters and not greater than 32."
  }
}

variable "containerRegistryUserAssignedIdentityId" {}

variable "containerAppsEnvironmentId" {}

variable "resourceGroupName" {}

variable "deployApp" {}

variable "workloadProfileName" {
  type    = string
}