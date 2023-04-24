resource "azurerm_application_insights" "app_insights" {
  name                = "appinsights-aca"
  location            = data.terraform_remote_state.spoke.outputs.rg.location
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
}

# todo : link application insights to ACA (not supported yet in terraform), should be done using azapi provider

# provider "azapi" {
# }