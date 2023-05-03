output "appInsightsName" {
  value = azurerm_application_insights.appInsights.name
}

output "appInsightsId" {
  value = azurerm_application_insights.appInsights.id
}

output "appInsightsInstrumentationKey" {
  value = azurerm_application_insights.appInsights.instrumentation_key
}

output "appInsightsConnectionString" {
  value = azurerm_application_insights.appInsights.connection_string
}

output "appInsightsAppId" {
  value = azurerm_application_insights.appInsights.app_id
}