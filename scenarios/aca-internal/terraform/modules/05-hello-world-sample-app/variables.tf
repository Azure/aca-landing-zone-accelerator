variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "helloWorldContainerAppName" {
  type    = string
  default = "ca-simple-hello"
  validation {
    condition     = length(var.helloWorldContainerAppName) >= 2 && length(var.helloWorldContainerAppName) <= 32
    error_message = "Name must be greater at least 2 characters and not greater than 32."
  }
}

variable "containerRegistryUserAssignedIdentityId" {
  type = string
}

variable "containerAppsEnvironmentId" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "resourceGroupId" {
  type = string
}

variable "deployApp" {
  type = bool
}
