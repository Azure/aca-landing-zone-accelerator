resource "azurerm_application_insights" "app_insights" {
  name                = "aca-appinsights"
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
}