variable "location" {
  default = "northeurope"
}

variable "tags" {
  type = map(string)

  default = {
    project = "aca-internal"
  }
}

variable "admin_password" {
  default = "change me"
}

variable "admin_username" {
  default = "sysadmin"
}