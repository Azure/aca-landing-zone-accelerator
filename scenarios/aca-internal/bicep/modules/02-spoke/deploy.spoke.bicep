targetScope = 'subscription'

// ------------------
//    PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param workloadName string

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string

@description('The location where the resources will be created. This should be the same region as the hub.')
param location string = deployment().location

@description('Optional. The name of the resource group to create the resources in. If set, it overrides the name generated by the template.')
param spokeResourceGroupName string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

// Hub
@description('The resource ID of the existing hub virtual network.')
param hubVNetId string

// Spoke
@description('CIDR of the spoke virtual network. For most landing zone implementations, the spoke network would have been created by your platform team.')
param spokeVNetAddressPrefixes array

@description('Optional. The name of the subnet to create for the spoke infrastructure. If set, it overrides the name generated by the template.')
param spokeInfraSubnetName string = 'snet-infra'

@description('CIDR of the spoke infrastructure subnet.')
param spokeInfraSubnetAddressPrefix string

@description('Optional. The name of the subnet to create for the spoke private endpoints. If set, it overrides the name generated by the template.')
param spokePrivateEndpointsSubnetName string = 'snet-pep'

@description('CIDR of the spoke private endpoints subnet.')
param spokePrivateEndpointsSubnetAddressPrefix string

@description('Optional. The name of the subnet to create for the spoke application gateway. If set, it overrides the name generated by the template.')
param spokeApplicationGatewaySubnetName string = 'snet-agw'

@description('CIDR of the spoke Application Gateway subnet. If the value is empty, this subnet will not be created.')
param spokeApplicationGatewaySubnetAddressPrefix string

@description('The IP address of the network appliance (e.g. firewall) that will be used to route traffic to the internet.')
param networkApplianceIpAddress string

// ------------------
// VARIABLES
// ------------------

// load as text (and not as Json) to replace <location> placeholder in the nsg rules
var nsgCaeRules = json( replace( loadTextContent('./nsgContainerAppsEnvironment.jsonc') , '<location>', location) )
var nsgAppGwRules = loadJsonContent('./nsgAppGwRules.jsonc', 'securityRules')
var namingRules = json(loadTextContent('../../../../shared/bicep/naming/naming-rules.jsonc'))

var rgSpokeName = !empty(spokeResourceGroupName) ? spokeResourceGroupName : '${namingRules.resourceTypeAbbreviations.resourceGroup}-${workloadName}-spoke-${environment}-${namingRules.regionAbbreviations[toLower(location)]}'
var hubVNetResourceIdTokens = !empty(hubVNetId) ? split(hubVNetId, '/') : array('')

@description('The ID of the subscription containing the hub virtual network.')
var hubSubscriptionId = hubVNetResourceIdTokens[2]

@description('The name of the resource group containing the hub virtual network.')
var hubResourceGroupName = hubVNetResourceIdTokens[4]

@description('The name of the hub virtual network.')
var hubVNetName = hubVNetResourceIdTokens[8]

// Subnet definition taking in consideration feature flags
var defaultSubnets = [
  {
    name: spokeInfraSubnetName
    properties: {
      addressPrefix: spokeInfraSubnetAddressPrefix
      networkSecurityGroup: {
        id: nsgContainerAppsEnvironment.outputs.nsgId
      }
      routeTable: {
        id: routeTable.outputs.resourceId
      }      
    }
  }
  {
    name: spokePrivateEndpointsSubnetName
    properties: {
      addressPrefix: spokePrivateEndpointsSubnetAddressPrefix
    }
  }
]

// Append optional application gateway subnet, if required
var spokeSubnets = !empty(spokeApplicationGatewaySubnetAddressPrefix) ? concat(defaultSubnets, [
    {
      name: spokeApplicationGatewaySubnetName
      properties: {
        addressPrefix: spokeApplicationGatewaySubnetAddressPrefix
        networkSecurityGroup: {
          id: nsgAppGw.outputs.nsgId
        }
      }
    }
  ]) : defaultSubnets

// ------------------
// RESOURCES
// ------------------


@description('The spoke resource group. This would normally be already provisioned by your subscription vending process.')
resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgSpokeName
  location: location
  tags: tags
}

@description('User-configured naming rules')
module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  scope: spokeResourceGroup
  name: take('02-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(spokeResourceGroup.id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}

@description('The spoke virtual network in which the workload will run from. This virtual network would normally already be provisioned by your subscription vending process, and only the subnets would need to be configured.')
module vnetSpoke '../../../../shared/bicep/vnet.bicep' = {
  name: take('vnetSpoke-${deployment().name}', 64)
  scope: spokeResourceGroup
  params: {
    name: naming.outputs.resourcesNames.vnetSpoke
    location: location
    tags: tags
    subnets: spokeSubnets
    vnetAddressPrefixes: spokeVNetAddressPrefixes
  }
}

@description('Network security group rules for the Container Apps cluster.')
module nsgContainerAppsEnvironment '../../../../shared/bicep/nsg.bicep' = {
  name: take('nsgContainerAppsEnvironment-${deployment().name}', 64)
  scope: spokeResourceGroup
  params: {
    name: naming.outputs.resourcesNames.containerAppsEnvironmentNsg
    location: location
    tags: tags
    securityRules: nsgCaeRules.securityRules
  }
}

@description('NSG Rules for the Application Gateway.')
module nsgAppGw '../../../../shared/bicep/nsg.bicep' = if (!empty(spokeApplicationGatewaySubnetAddressPrefix)) {
  name: take('nsgAppGw-${deployment().name}', 64)
  scope: spokeResourceGroup
  params: {
    name: naming.outputs.resourcesNames.applicationGatewayNsg
    location: location
    tags: tags
    securityRules: nsgAppGwRules
  }
}

@description('Spoke peering to regional hub network. This peering would normally already be provisioned by your subscription vending process.')
module peerSpokeToHub '../../../../shared/bicep/peering.bicep' = if (!empty(hubVNetId))  {
  name: take('${deployment().name}-peerSpokeToHubDeployment', 64)
  scope: spokeResourceGroup
  params: {
    localVnetName: vnetSpoke.outputs.vnetName
    remoteSubscriptionId: hubSubscriptionId
    remoteRgName: hubResourceGroupName
    remoteVnetName: hubVNetName
  }
}

@description('Regional hub peering to this spoke network. This peering would normally already be provisioned by your subscription vending process.')
module peerHubToSpoke '../../../../shared/bicep/peering.bicep' = if (!empty(hubVNetId)) {
  name: take('${deployment().name}-peerHubToSpokeDeployment', 64)
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    localVnetName: hubVNetName
    remoteSubscriptionId: last(split(subscription().id, '/'))!
    remoteRgName: spokeResourceGroup.name
    remoteVnetName: vnetSpoke.outputs.vnetName
  }
}

@description('The Route Table deployment')
module routeTable '../../../../shared/bicep/routeTables/main.bicep' = {
  name: take('routeTable-${uniqueString(spokeResourceGroup.id)}', 64)
  scope: spokeResourceGroup
  params: {
    name: naming.outputs.resourcesNames.routeTable
    location: location
    tags: tags
    routes: [
      {
        name: 'internetToFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: networkApplianceIpAddress
        }
      }
    ]
  }
}

// ------------------
// OUTPUTS
// ------------------

resource vnetSpokeCreated 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetSpoke.outputs.vnetName
  scope: spokeResourceGroup

  resource spokeInfraSubnet 'subnets' existing = {
    name: spokeInfraSubnetName
  }

  resource spokePrivateEndpointsSubnet 'subnets' existing = {
    name: spokePrivateEndpointsSubnetName
  }

  resource spokeApplicationGatewaySubnet 'subnets' existing = if (!empty(spokeApplicationGatewaySubnetAddressPrefix)) {
    name: spokeApplicationGatewaySubnetName
  }
}

@description('The name of the spoke resource group.')
output spokeResourceGroupName string = spokeResourceGroup.name

@description('The resource ID of the spoke virtual network.')
output spokeVNetId string = vnetSpokeCreated.id

@description('The name of the spoke virtual network.')
output spokeVNetName string = vnetSpokeCreated.name

@description('The resource ID of the spoke infrastructure subnet.')
output spokeInfraSubnetId string = vnetSpokeCreated::spokeInfraSubnet.id

@description('The name of the spoke infrastructure subnet.')
output spokeInfraSubnetName string = vnetSpokeCreated::spokeInfraSubnet.name

@description('The resource ID of the spoke private endpoints subnet.')
output spokePrivateEndpointsSubnetId string = vnetSpokeCreated::spokePrivateEndpointsSubnet.id

@description('The name of the spoke private endpoints subnet.')
output spokePrivateEndpointsSubnetName string = vnetSpokeCreated::spokePrivateEndpointsSubnet.name

@description('The resource ID of the spoke Application Gateway subnet. This is \'\' if the subnet was not created.')
output spokeApplicationGatewaySubnetId string = (!empty(spokeApplicationGatewaySubnetAddressPrefix)) ? vnetSpokeCreated::spokeApplicationGatewaySubnet.id : ''

@description('The name of the spoke Application Gateway subnet.  This is \'\' if the subnet was not created.')
output spokeApplicationGatewaySubnetName string = (!empty(spokeApplicationGatewaySubnetAddressPrefix)) ? vnetSpokeCreated::spokeApplicationGatewaySubnet.name : ''
