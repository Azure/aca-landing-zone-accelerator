@description('Required. Name of the OpenAI Account. Must be globally unique. Only alphanumeric characters and hyphens are allowed. The value must be 2-64 characters long and cannot start or end with a hyphen') 
@minLength(2)
@maxLength(64)
param name string

@description('Required. Name of the sample deployment. Deployment Name can have only letters and numbers, no spaces. Hyphens ("-") and underscores ("_") may be used, except as ending characters.')
@minLength(2)
@maxLength(64)
param deploymentName string = 'testGPT35'

@description('Optional. The location to deploy the Redis cache service.')
param location string 

@description('Optional. Tags of the resource.')
param tags object = {}

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The resource ID of the VNet to which the private endpoint will be connected.')
param spokeVNetId string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointSubnetName string

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('An existing Log Analytics WS Id for creating app Insights, diagnostics etc.')
param logAnalyticsWsId string

@description('Deploy (or not) a model on the openAI Account. This is used only as a sample to show how to deploy a model on the OpenAI account.')
param deployOpenAiGptModel bool = false



var hubVNetIdTokens = split(hubVNetId, '/')
var hubSubscriptionId = hubVNetIdTokens[2]
var hubResourceGroupName = hubVNetIdTokens[4]
var hubVNetName = hubVNetIdTokens[8]

var spokeVNetIdTokens = split(spokeVNetId, '/')
var spokeSubscriptionId = spokeVNetIdTokens[2]
var spokeResourceGroupName = spokeVNetIdTokens[4]
var spokeVNetName = spokeVNetIdTokens[8]

var virtualNetworkLinks = [
  {
    vnetName: spokeVNetName
    vnetId: vnetSpoke.id
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')
var openAiDnsZoneName = 'privatelink.openai.azure.com' 



resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  name: hubVNetName
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(spokeSubscriptionId, spokeResourceGroupName)
  name: spokeVNetName
}

resource spokePrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnetSpoke
  name: spokePrivateEndpointSubnetName
}


module openAI '../../../../../shared/bicep/cognitive-services/open-ai.bicep' = {
  name: 'openAI-${name}-Deployment'
  params: {
    name: name
    location: location
    tags: tags
    hasPrivateLinks: true
    diagnosticSettings: [
      {
        name: 'OpenAI-Default-Diag'        
        workspaceResourceId: logAnalyticsWsId
      }
    ]
  }
}

module gpt35TurboDeployment  '../../../../../shared/bicep/cognitive-services/open-ai.Gpt.deployment.bicep' = if (deployOpenAiGptModel) {
    name: 'GPT-${name}-Deployment'
    params: {
      openAiName: name
      deploymentName: deploymentName
    }
    dependsOn:[
      openAI
    ]
}

module openAiPrivateDnsZone '../../../../../shared/bicep/network/private-dns-zone.bicep' =  {
  // conditional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${replace(openAiDnsZoneName, '.', '-')}-PrivateDnsZoneDeployment', 64)
  params: {
    name: openAiDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peOpenAI '../../../../../shared/bicep/network/private-endpoint.bicep' = {
  name: take('pe-${name}-Deployment', 64)
  params: {
    name: take('pe-${name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: openAiPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: openAI.outputs.resourceId
    snetId: spokePrivateEndpointSubnet.id
    subresource: 'account'
  }
}
