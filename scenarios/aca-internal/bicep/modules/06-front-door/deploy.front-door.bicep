targetScope = 'resourceGroup'

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

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

// Container App Environment
@description('The ID of the Container Apps environment to be used for the deployment. (e.g. /subscriptions/XXX/resourceGroups/XXX/providers/Microsoft.App/managedEnvironments/XXX)')
param containerAppsEnvironmentId string

// Private Link Service
@description('The resource ID of the subnet to be used for the private link service. (e.g. /subscriptions/XXX/resourceGroups/XXX/providers/Microsoft.Network/virtualNetworks/XXX/subnets/XXX)')
param privateLinkSubnetId string

@description('The name of the front door endpoint to be created.')
param frontDoorEndpointName string = 'fde-containerapps'

@description('The name of the front door origin group to be created.')
param frontDoorOriginGroupName string = 'containerapps-origin-group'

@description('The name of the front door origin to be created.')
param frontDoorOriginName string = 'containerapps-origin'

@description('The name of the front door origin route to be created.')
param frontDoorOriginRouteName string = 'containerapps-route'

@description('The host name of the front door origin to be created.')
param frontDoorOriginHostName string

// ------------------
// VARIABLES
// ------------------

var containerAppsEnvironmentTokens = split(containerAppsEnvironmentId, '/')
var containerAppsEnvironmentSubscriptionId = containerAppsEnvironmentTokens[2]
var containerAppsEnvironmentResourceGroupName = containerAppsEnvironmentTokens[4]
var containerAppsEnvironmentName = containerAppsEnvironmentTokens[8]

var privateLinkServiceName = '${naming.outputs.resourceTypeAbbreviations.privateLinkService}-${naming.outputs.resourcesNames.frontDoor}'

// ------------------
// RESOURCES
// ------------------

module naming '../../../../shared/bicep/naming/naming.module.bicep' = {
  name: take('06-sharedNamingDeployment-${deployment().name}', 64)
  params: {
    uniqueId: uniqueString(resourceGroup().id)
    environment: environment
    workloadName: workloadName
    location: location
  }
}


resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  scope: resourceGroup(containerAppsEnvironmentSubscriptionId, containerAppsEnvironmentResourceGroupName)
  name: containerAppsEnvironmentName
}

module privateLinkService './modules/private-link-service.bicep' = {
  name: 'privateLinkServiceFrontDoorDeployment-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    tags: tags
    containerAppsDefaultDomainName: containerAppsEnvironment.properties.defaultDomain
    containerAppsEnvironmentSubscriptionId: containerAppsEnvironmentSubscriptionId
    privateLinkServiceName: privateLinkServiceName
    privateLinkSubnetId: privateLinkSubnetId
  }
}

module frontDoor './modules/front-door.bicep' = {
  name: 'frontDoorDeployment-${uniqueString(resourceGroup().id)}'
  params: {
    location: location
    tags: tags
    frontDoorEndpointName: frontDoorEndpointName
    frontDoorOriginGroupName: frontDoorOriginGroupName
    frontDoorOriginHostName: frontDoorOriginHostName
    frontDoorOriginName: frontDoorOriginName
    frontDoorOriginRouteName: frontDoorOriginRouteName
    frontDoorProfileName: naming.outputs.resourcesNames.frontDoor
    privateLinkServiceId: privateLinkService.outputs.privateLinkServiceId
  }
}

// resource existingPrivateLinkService 'Microsoft.Network/privateLinkServices@2022-01-01' existing = {
//   name: privateLinkServiceName
// }

// ------------------
// OUTPUTS
// ------------------

// Outputs including the private link endpoint connection ID to approve
output result object = {
  fqdn: frontDoor.outputs.fqdn
  privateLinkServiceId: privateLinkService.outputs.privateLinkServiceId
  privateLinkEndpointConnectionId: length(privateLinkService.outputs.privateEndpointConnections) > 0 ? filter(privateLinkService.outputs.privateEndpointConnections, (connection) => connection.properties.privateLinkServiceConnectionState.description == 'frontdoor')[0].id : ''
}
