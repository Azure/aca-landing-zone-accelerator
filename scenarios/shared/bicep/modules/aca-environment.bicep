@description('Required. Name of your Azure Container Apps Environment. ')
param name string

@description('Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional, default value is false. Sets if the environment will use availability zones. Your Container App Environment and the apps in it will be zone redundant. This requieres vNet integration.')
param zoneRedundant bool = false

@description('Mandatory, default is Consumption')
@allowed([
  'Consumption'
  'Premium'
])
param sku string= 'Consumption'

@description('If true, the endpoint is an internal load balancer. If false the hosted apps are exposed on an internet-accessible IP address ')
param vnetEndpointInternal bool

@description('Custome vnet configuration for the nevironment. NOTE: Current GA (Feb 2023): The subnet associated with a Container App Environment requires a CIDR prefix of /23 or larger')
param subnetId string

@description('mandatory for log-analytics')
param logAnalyticsWsResourceId string

@description('optional, default is empty. App Insights instrumentation key provided to Dapr for tracing')
param appInsightsInstrumentationKey string = ''

var lawsSplitTokens = !empty(logAnalyticsWsResourceId) ? split(logAnalyticsWsResourceId, '/') : array('')

resource laws 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(logAnalyticsWsResourceId) ) {
  scope: resourceGroup(lawsSplitTokens[2], lawsSplitTokens[4])
  name: lawsSplitTokens[8]
}

resource acaEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  tags: tags
  properties: {
    zoneRedundant: zoneRedundant
    daprAIInstrumentationKey: appInsightsInstrumentationKey
    vnetConfiguration: {
      internal: vnetEndpointInternal
      infrastructureSubnetId: subnetId
      outboundSettings:{
        outBoundType: 'LoadBalancer'
      }
    }

    appLogsConfiguration:  {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: laws.properties.customerId
        sharedKey: laws.listKeys().primarySharedKey
      }
    }
  }
}

@description('The Name of the Azure container app environment.')
output acaEnvName string = acaEnv.name

@description('The resource ID of the Azure container app environment.')
output acaEnvResourceId string = acaEnv.id

@description('The default domain of the Azure container app environment.')
output acaEnvDefaultDomain string = acaEnv.properties.defaultDomain

@description('The Azure container app environment\'s Load Balancer IP.')
output acaEnvLoadBalancerIP string = acaEnv.properties.staticIp