# Diagnostic Settings
data "azurerm_monitor_diagnostic_categories" "resources" {
  for_each = { for resource in var.resources : resource.type => resource }

  resource_id = each.value.id
}

resource "azurerm_monitor_diagnostic_setting" "rule" {
  for_each = { for resource in var.resources : resource.type => resource }

  name                           = "${each.key}-diagnostic-setting"
  target_resource_id             = each.value.id
  log_analytics_workspace_id     = var.logAnalyticsWorkspaceId
  log_analytics_destination_type = "AzureDiagnostics"

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.resources[each.key].log_category_types

    content {
      category = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.resources[each.key].metrics

    content {
      category = entry.value
      enabled  = true
    }
  }
}
