targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------
@minLength(2)
@maxLength(10)
@description('The name of the workloard that is being deployed. Up to 10 characters long.')
param workloadName string

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa") Up to 8 characters long.')
@maxLength(8)
param environment string

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Enable or disable the createion of Application Insights.')
param enableApplicationInsights bool

@description('Enable or disable Dapr Application Instrumentation Key used for Dapr telemetry. If Application Insights is not enabled, this parameter is ignored.')
param enableDaprInstrumentation bool

@description('The name of the spoke VNet.')
param spokeVNetName string

@description('The name of the spoke infrastructure subnet.')
param spokeInfraSubnetName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

// ------------------
// VARIABLES
// ------------------

var hubVNetResourIdTokens = !empty(hubVNetId) ? split(hubVNetId, '/') : array('')
var hubSubscriptionId = hubVNetResourIdTokens[2]
var hubResourceGroupName = hubVNetResourIdTokens[4]
var hubVNetName = hubVNetResourIdTokens[8]

var spokeVNetLinks = [
  {
    vnetName: spokeVNetName
    vnetId: spokeVNet.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var telemetryId = '9b4433d6-924a-4c07-b47c-7478619759c7-${location}-acasb'

// ------------------
// RESOURCES
// ------------------

module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('04-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource spokeVNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: spokeVNetName
}

resource spokeInfraSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: spokeVNet
  name: spokeInfraSubnetName
}

module logAnalyticsWorkspace '../../../../shared/bicep/log-analytics-ws.bicep' = {
  name: take('logAnalyticsWs-${uniqueString(resourceGroup().id)}', 64)
  params: {
    location: location
    name: naming.outputs.resourcesNames.logAnalyticsWorkspace
  }
}

module applicationInsights '../../../../shared/bicep/app-insights.bicep' = if (enableApplicationInsights) {
  name: take('applicationInsights-${uniqueString(resourceGroup().id)}', 64)
  params: {
    name: naming.outputs.resourcesNames.applicationInsights
    location: location
    tags: tags    
    workspaceResourceId: logAnalyticsWorkspace.outputs.logAnalyticsWsId
  }
}

module containerAppsEnvironment '../../../../shared/bicep/aca-environment.bicep' = {
  name: take('containerAppsEnvironment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    name: naming.outputs.resourcesNames.containerAppsEnvironment
    location: location
    tags: tags
    logAnalyticsWsResourceId: logAnalyticsWorkspace.outputs.logAnalyticsWsId     
    subnetId: spokeInfraSubnet.id
    vnetEndpointInternal: true
    appInsightsInstrumentationKey: (enableApplicationInsights && enableDaprInstrumentation)  ? applicationInsights.outputs.appInsInstrumentationKey : ''
  }
}

module containerAppsEnvironmentPrivateDnsZone  '../../../../shared/bicep/private-dns-zone.bicep' = {
  name: 'containerAppsEnvironmentPrivateDnsZone-${uniqueString(resourceGroup().id)}'
  params: {
    name: containerAppsEnvironment.outputs.containerAppsEnvironmentDefaultDomain
    virtualNetworkLinks: spokeVNetLinks
    tags: tags
    aRecords: [
      {
        name: '*'
        ipv4Address: containerAppsEnvironment.outputs.containerAppsEnvironmentLoadBalancerIP
      }
    ]
  }
}

//  Telemetry Deployment
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the container apps environment.')
output containerAppsEnvironmentId string = containerAppsEnvironment.outputs.containerAppsEnvironmentNameId

@description('The name of the container apps environment.')
output containerAppsEnvironmentName string = containerAppsEnvironment.outputs.containerAppsEnvironmentName

@description('The customer id of the log analytics workspace.')
output logAnalyticsWorkspaceCustomerId string = logAnalyticsWorkspace.outputs.customerId
