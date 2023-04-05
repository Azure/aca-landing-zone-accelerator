resource "azurerm_container_registry" "acr" {
    name = var.acrName
    resource_group_name = var.resourceGroupName
    location = var.location
    tags = var.tags

    sku = "Premium"

    admin_enabled = false 
    public_network_access_enabled = false
    network_rule_bypass_option = "AzureServices"
}

module "privateNetworking" {
  
}