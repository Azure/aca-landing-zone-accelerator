# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50.0"
    }
  }
  required_version = ">= 1.3.4"

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate2074974790"
    container_name       = "tfstate"
    key                  = "aca-lz/terraform.tfstate"
  }
}

provider "azurerm" {
  disable_terraform_partner_id = !(var.enableTelemetry)
  partner_id                   = "9b4433d6-924a-4c07-b47c-7478619759c7"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}