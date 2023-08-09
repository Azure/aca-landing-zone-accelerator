// ------------------
//    PARAMETERS
// ------------------
variable "workloadName" {
  type = string
  validation {
    condition     = length(var.workloadName) >= 2 && length(var.workloadName) <= 10
    error_message = "Name must be greater at least 2 characters and not greater than 10."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = length(var.environment) <= 8
    error_message = "Environment name can't be greater than 8 characters long."
  }
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "containerAppsEnvironmentId" {}

variable "containerAppsDefaultDomainName" {}

variable "privateLinkSubnetId" {
  type = string
}

variable "resourceGroupName" {}

variable "frontDoorEndpointName" {
  default = "fde-containerapps"
}

variable "tags" {}

variable "frontDoorOriginGroupName" {
  default = "containerapps-origin-group"
}

variable "frontDoorOriginName" {
  default = "containerapps-origin"
}

variable "frontDoorOriginRouteName" {
  default = "containerapps-route"
}

variable "frontDoorOriginHostName" {}

variable "logAnalyticsWorkspaceId" {}