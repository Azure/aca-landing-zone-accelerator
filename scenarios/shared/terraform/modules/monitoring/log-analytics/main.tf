resource "azurerm_log_analytics_workspace" "laws" {
  name                = var.workspaceName
  resource_group_name = var.resourceGroupName
  location            = var.location
  tags                = var.tags
  retention_in_days   = var.retentionInDays
  sku                 = var.sku

  internet_ingestion_enabled      = var.ingestionEnabled
  internet_query_enabled          = var.internetQueryEnabled
  allow_resource_only_permissions = var.allowResourceOnlyPermissions
}
