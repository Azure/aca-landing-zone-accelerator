variable "location" {
  default = "northeurope"
}

variable "rg_name" {
  default = "rg-spoke"
}

variable "tags" {
  type = map(string)

  default = {
    project = "aca-internal"
  }
}