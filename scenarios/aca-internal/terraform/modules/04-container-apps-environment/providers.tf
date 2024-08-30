# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0"
    }
  }
  required_version = ">= 1.3.4"

  # backend "azurerm" {
  # }
}
provider "azurerm" {
  subscription_id = var.subscription_id
  partner_id = var.enableTelemetry ? "9b4433d6-924a-4c07-b47c-7478619759c7" : null
  features {}
}