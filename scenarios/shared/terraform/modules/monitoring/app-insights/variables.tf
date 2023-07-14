variable "appInsightsName" {
  default = ""
  type    = string
  validation {
    condition     = length(var.appInsightsName) >= 4 && length(var.appInsightsName) <= 63
    error_message = "Name must be greater than 4 characters and not longer than 63 characters."
  }
}

variable "resourceGroupName" {
  type = string
}

variable "location" {
  default = "northeurope"
  type    = string
}

variable "retentionInDays" {
  default = 90
  type    = number
  validation {
    condition     = var.retentionInDays <= 730
    error_message = "Value can't be more than 730 days."
  }
}

variable "tags" {

}

variable "ingestionEnabled" {
  default = true
  type    = bool
}

variable "internetQueryEnabled" {
  default = true
  type    = bool

}

variable "samplingPercentage" {
  default = 100
  type    = number
  validation {
    condition     = var.samplingPercentage >= 0 && var.samplingPercentage <= 100
    error_message = "Value must be between 0 and 100."
  }
}

variable "applicationType" {
  default = "web"
  type    = string
  validation {
    condition = anytrue([
      var.applicationType == "web",
      var.applicationType == "other"
    ])
    error_message = "Application Type must be either web or other."
  }
}

variable "workspaceId" {
  type = string
}