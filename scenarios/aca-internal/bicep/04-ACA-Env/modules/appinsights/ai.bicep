param location string = resourceGroup().location
param name string
param laworkspaceId string
// var logAnalyticsWorkspaceName = 'logs-${environment_name}'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appins-${name}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: laworkspaceId
  }
}

output appInsightsName string = appInsights.name
