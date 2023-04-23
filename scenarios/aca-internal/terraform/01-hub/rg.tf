# Resource Group for Hub

resource "azurerm_resource_group" "rg" {
  name     = "rg-hub"
  location = var.location
  tags = var.tags
}