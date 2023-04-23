# resource group for spoke resources
resource "azurerm_resource_group" "rg" {
  name     = "rg-spoke"
  location = var.location
}