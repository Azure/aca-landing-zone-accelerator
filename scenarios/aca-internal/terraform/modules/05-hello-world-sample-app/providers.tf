# Configure the Azure provider
terraform {
  required_providers {
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~> 3.70.0"
    # }
    
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.8.0"
    }
  }
  required_version = ">= 1.3.4"
}