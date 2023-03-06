targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

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


// ------------------
// RESOURCES
// ------------------

module naming '../modules/naming/naming.module.bicep' = {
  name: take('04-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
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

module logAnalyticsWorkspace '../modules/log-analytics-ws.bicep' = {
  name: take('logAnalyticsWs-Deployment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    location: location
    name: naming.outputs.resourcesNames.logAnalyticsWorkspace
  }
}

module applicationInsights '../modules/app-insights.bicep' = if (enableApplicationInsights) {
  name: take('applicationInsights-Deployment-${uniqueString(resourceGroup().id)}', 64)
  params: {
    name: naming.outputs.resourcesNames.appInsights
    location: location
    tags: tags    
    workspaceResourceId: logAnalyticsWorkspace.outputs.logAnalyticsWsId
  }
}

module containerAppsEnvironment '../modules/aca-environment.bicep' = {
  name: take('containerAppsEnvironment-Deployment-${uniqueString(resourceGroup().id)}', 64)
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

module containerAppsEnvironmentPrivateDnsZone  '../modules/private-dns-zone.bicep' = {
  name: 'containerAppsEnvironmentPrivateDnsZone-Deployment-${uniqueString(resourceGroup().id)}'
  params: {
    name: containerAppsEnvironment.outputs.acaEnvDefaultDomain
    virtualNetworkLinks: spokeVNetLinks
    tags: tags
    aRecords: [
      {
        name: '*'
        ipv4Address: containerAppsEnvironment.outputs.acaEnvLoadBalancerIP
      }
    ]
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The resource ID of the container apps environment.')
output containerAppsEnvironmentId string = containerAppsEnvironment.outputs.acaEnvResourceId

@description('The name of the container apps environment.')
output containerAppsEnvironmentName string = containerAppsEnvironment.outputs.acaEnvName
