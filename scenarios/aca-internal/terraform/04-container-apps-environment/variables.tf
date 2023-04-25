variable "tags" {
  type = map(string)

  default = {
    project = "aca-internal"
  }
}

variable "log_analytics_workspace" {
  default = "aca-internal-log-analytics"
}