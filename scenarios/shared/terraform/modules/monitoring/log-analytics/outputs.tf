output "workspaceName" {
  value = azurerm_log_analytics_workspace.laws.name
}

output "customerId" {
  value = azurerm_log_analytics_workspace.laws.workspace_id
}

output "id" {
  value = azurerm_log_analytics_workspace.laws.id
}

output "sharedKey" {
  value = azurerm_log_analytics_workspace.laws.primary_shared_key
}