variable "network_name" {
    default = ""
    type = string
    validation {
      condition = length(var.network_name) >= 2 || length(var.network_name) > 32
      error_message = "Name must be at least 2 characters long and not longer than 32."

    }
}

variable "location" {
    default = "eastus"
    type = string
}

variable "resource_group_name" {
    default = ""
    type = string
}

variable "address_space" {
    default = []
    type = list(string)
}

variable "tags" {
}

variable "ddos_protection_plan_id" {
    default = ""
    type = string
}

variable "subnets" {
    default = []
}