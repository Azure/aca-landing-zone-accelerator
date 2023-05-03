output "workspaceName" {
  value = azurerm_log_analytics_workspace.laws.name
}

output "workspaceId" {
  value = azurerm_log_analytics_workspace.laws.id
}

## Need to clarify on this one
output "customerId" {
  value = ""
}
