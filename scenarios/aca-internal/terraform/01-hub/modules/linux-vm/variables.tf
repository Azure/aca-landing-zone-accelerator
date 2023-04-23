variable "admin_username" {
  default = "sysadmin"
}

variable "admin_password" {
  default = "changeme"
}

variable "server_name" {}

variable "resource_group_name" {}

variable "location" {}

variable "vnet_subnet_id" {}

variable "os_publisher" {
  default = "Canonical"
}

variable "os_offer" {
  default = "UbuntuServer"
}

variable "os_sku" {
  default = "18.04-LTS"
}

variable "os_version" {
  default = "latest"
}

variable "disable_password_authentication" {
  default = false #leave as true if using ssh key, if using a password make the value false
}

variable "enable_accelerated_networking" {
  default = "false"
}

variable "storage_account_type" {
  default = "Standard_LRS"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "tags" {
  type = map(string)

  default = {
    application = "compute"
  }
}

variable "allocation_method" {
  default = "Static"
}