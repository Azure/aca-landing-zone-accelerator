# Configure the Azure provider
terraform {
  required_providers {
    key_vault {
        purge_soft_delete_on_destroy = true
    }
    
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50.0"
    }
  }
  required_version = ">= 1.3.4"

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}