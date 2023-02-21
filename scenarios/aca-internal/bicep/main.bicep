targetScope = 'subscription'

// ================ //
// Parameters       //
// ================ //

@description('suffix that will be used to name the resources in a pattern like <resourceAbbreviation>-<applicationName>')
param applicationName string

@description('Azure region where the resources will be deployed in')
param location string

@description('Required. The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param spokeVnetAddressSpace string

@description('CIDR of the subnet hosting Azure Container App Environment. For the current version (Feb 2023) you need at least /23 network')
param subnetInfraAddressSpace string

@description('CIDR of the subnet hosting the private endpoints of any desired servies (key vault, ACR, DBs etc')
param subnetPrivateEndpointAddressSpace string

@description('CIDR of the subnet hosting the application Gateway V2. needs to be big enough to accomdate scaling')
param subnetAppGwAddressSpace string

@description('Optional. A numeric suffix (e.g. "001") to be appended on the naming generated for the resources. Defaults to empty.')
param numericSuffix string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param resourceTags object = {}

//TODO: Ask arthi for Telemetry GUID
// @description('Telemetry is by default enabled. The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services.')
// param enableTelemetry bool = true

@description('If you need peering between spoke and hub vnet, then you need to give the remote hub vnet resource ID')
param vnetHubResourceId string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN  string 

@description('If true, then application Insights will be deployed to provide tracing facility for DAPR in azure container apps')
param acaDaprTracingWithAppInsights bool 


// ================ //
// Variables        //
// ================ //

var tags = union({
  applicationName: applicationName
  environment: environment
}, resourceTags)

var resourceSuffix = '${applicationName}-${environment}-${location}'
var spokeResourceGroupName = 'rg-spoke-${resourceSuffix}'

var defaultSuffixes = [
  applicationName
  environment
  '**location**'
]
var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [
  numericSuffix
])

var vnetHubResourceIdSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

// ================ //
// Resources        //
// ================ //

// TODO: Must be shared among diferrent scenarios: Change in ASE (tt20230129)
module naming '../../shared/bicep/modules/naming.module.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: 'namingModule-Deployment'
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: spokeResourceGroupName
  location: location
  tags: tags
}


module spokeResources 'spoke.deployment.bicep' = {
  scope: resourceGroup(spokeResourceGroup.name)
  name: 'spokeDeployment'
  params: {
    naming: naming.outputs.names
    location: location
    tags: tags
    spokeVnetAddressSpace: spokeVnetAddressSpace
    appGatewayFQDN: appGatewayFQDN
    acaDaprTracingWithAppInsights: acaDaprTracingWithAppInsights
    subnetAppGwAddressSpace: subnetAppGwAddressSpace
    subnetInfraAddressSpace: subnetInfraAddressSpace
    subnetPrivateEndpointAddressSpace: subnetPrivateEndpointAddressSpace
  }
}

module peerSpokeToHub '../../shared/bicep/modules/network/peering.bicep' = if (!empty(vnetHubResourceId) )  {
  name: 'peerSpokeToHubDeployment'
  scope: resourceGroup(last(split(subscription().id, '/'))!, spokeResourceGroup.name)
  params: {
    localVnetName: spokeResources.outputs.vnetSpokeName
    remoteVnetName: vnetHubResourceIdSplitTokens[8]
    remoteRgName: vnetHubResourceIdSplitTokens[4]
    remoteSubscriptionId: vnetHubResourceIdSplitTokens[2]
  }
}

module peerHubToSpoke '../../shared/bicep/modules/network/peering.bicep' = if (!empty(vnetHubResourceId) )  {
  name: 'peerHubToSpokeDeployment'
  scope: resourceGroup(vnetHubResourceIdSplitTokens[2], vnetHubResourceIdSplitTokens[4])
    params: {
      localVnetName: vnetHubResourceIdSplitTokens[8]
      remoteVnetName: spokeResources.outputs.vnetSpokeName
      remoteRgName: spokeResourceGroup.name
      remoteSubscriptionId: last(split(subscription().id, '/'))!
  }
}

// //TODO: need to find Deployment GUID
// //  Telemetry Deployment
// @description('Enable usage and telemetry feedback to Microsoft.')
// var telemetryId = 'cf7e9f0a-f872-49db-b72f-f2e318189a6d-${location}-msb'
// resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
//   name: telemetryId
//   location: location
//   properties: {
//     mode: 'Incremental'
//     template: {
//       '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
//       contentVersion: '1.0.0.0'
//       resources: {}
//     }
//   }
// }
