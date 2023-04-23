variable "location" {
  default = "northeurope"
}

variable "tags" {
  type = map(string)

  default = {
    project = "aca-internal"
  }
}

variable "hub_prefix" {
  default = "escs-hub"
}

variable "sku_name" {
  default = "AZFW_VNet"
}

variable "sku_tier" {
  default = "Standard"
}

variable "admin_password" {
  default = "change me"
}

variable "admin_username" {
  default = "sysadmin"
}

## Sensitive Variables for the Jumpbox
## Sample terraform.tfvars File

# admin_password = "ChangeMe"
# admin_username = "sysadmin"
