resource "azurerm_application_insights" "appInsights" {
  name                = var.appInsightsName
  resource_group_name = var.resourceGroupName
  location            = var.location
  tags                = var.tags

  application_type = var.applicationType
  workspace_id     = var.workspaceId

  internet_ingestion_enabled = var.ingestionEnabled
  internet_query_enabled     = var.internetQueryEnabled

  retention_in_days = var.retentionInDays

  sampling_percentage = var.samplingPercentage
}