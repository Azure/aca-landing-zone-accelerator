@description('Required. Name of the Application Insights.')
param name string

@description('Optional. Application type.')
@allowed([
  'web'
  'other'
])
param appInsightsType string = 'web'

@description('Optional, default value, empty. Resource ID of the log analytics workspace which the data will be ingested to. If left empty, appInsights will create one for us. This property is required to create an application with this API version. Applications from older versions will not have this property.')
param workspaceResourceId string = ''

@description('Optional. The network access type for accessing Application Insights ingestion. - Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. The network access type for accessing Application Insights query. - Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Optional. Retention period in days.')
@allowed([
  30
  60
  90
  120
  180
  270
  365
  550
  730
])
param retentionInDays int = 90

@description('Optional. Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry.')
@minValue(0)
@maxValue(100)
param samplingPercentage int = 100

@description('Optional. The kind of application that this component refers to, used to customize UI. This value is a freeform string, values should typically be one of the following: web, ios, other, store, java, phone.')
param kind string = ''

@description('Optional. Location for all Resources.')
param location string


@description('Optional. Tags of the resource.')
param tags object = {}

var lawsMaxLength = 63
var lawsNameSantized = replace(name, 'appi-', 'log-')
var lawsName = length(lawsNameSantized) > lawsMaxLength ? substring(lawsNameSantized, 0, lawsMaxLength) : lawsNameSantized

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: appInsightsType
    Request_Source: 'rest'
    WorkspaceResourceId: empty(workspaceResourceId) ? laws.outputs.logAnalyticsWsId : workspaceResourceId
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    RetentionInDays: retentionInDays
    SamplingPercentage: samplingPercentage
  }
}

module laws 'log-analytics-ws.bicep' = if ( empty(workspaceResourceId) ) {
  name: 'lawsDeployment'
  params: {
    location: location
    name: lawsName
    tags: tags
  }
}

@description('The name of the application insights component.')
output appInsNname string = appInsights.name

@description('The resource ID of the application insights component.')
output appInsResourceId string = appInsights.id

@description('The name of the auto-create Log Analytics WS resource.')
output logAnalyticsWsName string = empty(workspaceResourceId) ? laws.outputs.logAnalyticsWsName : ''

@description('The Log Analytics WS resource ID of the application Inishgrs.')
output logAnalyticsWsId string = empty(workspaceResourceId) ? laws.outputs.logAnalyticsWsId : workspaceResourceId

@description('The application ID of the application insights component.')
output applicationId string = appInsights.properties.AppId
