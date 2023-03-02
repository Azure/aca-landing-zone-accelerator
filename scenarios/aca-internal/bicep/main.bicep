targetScope = 'subscription'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = deployment().location

@description('Optional. The prefix to be used for all resources created by this template.')
param prefix string = ''

@description('Optional. The suffix to be used for all resources created by this template.')
param suffix string = ''

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

// Hub Virtual Network
@description('The address prefixes to use for the virtual network.')
param vnetAddressPrefixes array

// Hub Bastion
@description('Enable or disable the creation of the Azure Bastion.')
param enableBastion bool

@description('CIDR to use for the Azure Bastion subnet.')
param bastionSubnetAddressPrefix string

// Hub Virtual Machine
@description('The size of the virtual machine to create. See https://docs.microsoft.com/en-us/azure/virtual-machines/sizes for more information.')
param vmSize string

@description('The username to use for the virtual machine.')
param vmAdminUsername string

@secure()
@description('The password to use for the virtual machine.')
param vmAdminPassword string

@secure()
@description('The SSH public key to use for the virtual machine.')
param vmLinuxSshAuthorizedKeys string

@allowed(['linux', 'windows', 'none'])
param vmJumpboxOSType string = 'none'

@description('CIDR to use for the virtual machine subnet.')
param vmJumpBoxSubnetAddressPrefix string

// Spoke
@description('Optional. The name of the resource group to create the resources in. If set, it overrides the name generated by the template.')
param spokeResourceGroupName string = '${prefix}rg-spoke${suffix}'

@description('CIDR of the Spoke Virtual Network.')
param spokeVNetAddressPrefixes array

@description('CIDR of the Spoke Infrastructure Subnet.')
param spokeInfraSubnetAddressPrefix string

@description('CIDR of the Spoke Private Endpoints Subnet.')
param spokePrivateEndpointsSubnetAddressPrefix string

@description('CIDR of the Spoke Application Gateway Subnet.')
param spokeApplicationGatewaySubnetAddressPrefix string

@description('Enable or disable the createion of Application Insights.')
param enableApplicationInsights bool

@description('Enable or disable Dapr Application Instrumentation Key used for Dapr telemetry. If Application Insights is not enabled, this parameter is ignored.')
param enableDaprInstrumentation bool

@description('Enable or disable the deployment of the Hello World Sample App. If disabled, the Application Gateway will not be deployed.')
param deployHelloWorldSample bool

@description('The FQDN of the Application Gateawy. Must match the TLS Certificate.')
param applicationGatewayFQDN string

@description('Enable or disable Application Gateway Certificate (PFX).')
param enableApplicationGatewayCertificate bool

@description('The name of the certificate key to use for Application Gateway certificate.')
param applicationGatewayCertificateKeyName string

@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true


// ------------------
//    VARIABLES
// ------------------

var telemetryId = '9b4433d6-924a-4c07-b47c-7478619759c7-${location}-acasb'


// ------------------
// DEPLOYMENT TASKS
// ------------------

module hub '01-hub/main.bicep' = {
  name: '${deployment().name}-hub'
  params: {
    location: location
    prefix: prefix
    suffix: suffix
    tags: tags
    vnetAddressPrefixes: vnetAddressPrefixes
    enableBastion: enableBastion
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
    vmSize: vmSize
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmLinuxSshAuthorizedKeys: vmLinuxSshAuthorizedKeys
    vmJumpboxOSType: vmJumpboxOSType
    vmJumpBoxSubnetAddressPrefix: vmJumpBoxSubnetAddressPrefix
  }
}

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: spokeResourceGroupName
  location: location
  tags: tags
}

module spoke '02-spoke/main.bicep' = {
  name: '${deployment().name}-spoke'
  params: {
    spokeResourceGroupName: spokeResourceGroup.name
    location: location
    prefix: prefix
    suffix: suffix
    tags: tags
    hubVNetId:  hub.outputs.hubVNetId
    spokeApplicationGatewaySubnetAddressPrefix: spokeApplicationGatewaySubnetAddressPrefix
    spokeInfraSubnetAddressPrefix: spokeInfraSubnetAddressPrefix
    spokePrivateEndpointsSubnetAddressPrefix: spokePrivateEndpointsSubnetAddressPrefix
    spokeVNetAddressPrefixes: spokeVNetAddressPrefixes
  }
}

module supportingServices '03-supporting-services/main.bicep' = {
  name: '${deployment().name}-supportingServices'
  scope: spokeResourceGroup
  params: {
    location: location
    prefix: prefix
    suffix: suffix
    tags: tags
    spokePrivateEndpointSubnetName: spoke.outputs.spokePrivateEndpointsSubnetName
    spokeVNetId: spoke.outputs.spokeVNetId
    hubVNetId: hub.outputs.hubVNetId
  }
}

module containerAppsEnvironment '04-container-apps-environment/main.bicep' = {
  name: '${deployment().name}-containerAppsEnvironment'
  scope: spokeResourceGroup
  params: {
    location: location
    prefix: prefix
    suffix: suffix
    tags: tags
    hubVNetId:  hub.outputs.hubVNetId
    spokeVNetName: spoke.outputs.spokeVNetName
    spokeInfraSubnetName: spoke.outputs.spokeInfraSubnetName
    enableApplicationInsights: enableApplicationInsights
    enableDaprInstrumentation: enableDaprInstrumentation
  }
}

module helloWorlSampleApp '05-hello-world-sample-app/main.bicep' = if (deployHelloWorldSample) {
  name: '${deployment().name}-helloWorlSampleApp'
  scope: spokeResourceGroup
  params: {
    location: location
    tags: tags
    containerRegistryUserAssignedIdentityId: supportingServices.outputs.containerRegistryUserAssignedIdentityId
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.containerAppsEnvironmentId
  }
}

module applicationGateway '06-application-gateway/main.bicep' = if (deployHelloWorldSample) {
  name: '${deployment().name}-applicationGateway'
  scope: spokeResourceGroup
  params: {
    location: location
    prefix: prefix
    suffix: suffix
    tags: tags
    applicationGatewayCertificateKeyName: applicationGatewayCertificateKeyName
    applicationGatewayFQDN: applicationGatewayFQDN
    applicationGatewayPrimaryBackendEndFQDN: (deployHelloWorldSample) ? helloWorlSampleApp.outputs.helloWorldAppFQDN : '' // To fix issue when hello world is not deployed
    applicationGatewaySubnetId: spoke.outputs.spokeApplicationGatewaySubnetId
    enableApplicationGatewayCertificate: enableApplicationGatewayCertificate
    keyVaultId: supportingServices.outputs.keyVaultId
  }
}

//  Telemetry Deployment
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  location: location
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

// Hub
@description('The resource ID of hub virtual network.')
output hubVNetId string = hub.outputs.hubVNetId

// Spoke
@description('The name of the Hub resource group.')
output spokeResourceGroupName string = spokeResourceGroup.name

@description('The  resource ID of the Spoke Virtual Network.')
output spokeVNetId string = spoke.outputs.spokeVNetId

@description('The name of the Spoke Virtual Network.')
output spokeVnetName string = spoke.outputs.spokeVNetName

@description('The resource ID of the Spoke Infrastructure Subnet.')
output spokeInfraSubnetId string = spoke.outputs.spokeInfraSubnetId

@description('The name of the Spoke Infrastructure Subnet.')
output spokeInfraSubnetName string = spoke.outputs.spokeInfraSubnetName

@description('The resource ID of the Spoke Private Endpoints Subnet.')
output spokePrivateEndpointsSubnetId string = spoke.outputs.spokePrivateEndpointsSubnetId

@description('The name of the Spoke Private Endpoints Subnet.')
output spokePrivateEndpointsSubnetName string = spoke.outputs.spokePrivateEndpointsSubnetName

@description('The resource ID of the Spoke Application Gateway Subnet. If "spokeApplicationGatewaySubnetAddressPrefix" is empty, the subnet will not be created and the value returned is empty.')
output spokeApplicationGatewaySubnetId string = spoke.outputs.spokeApplicationGatewaySubnetId

@description('The name of the Spoke Application Gateway Subnet.  If "spokeApplicationGatewaySubnetAddressPrefix" is empty, the subnet will not be created and the value returned is empty.')
output spokeApplicationGatewaySubnetName string = spoke.outputs.spokeApplicationGatewaySubnetName

// Supporting Services
@description('The resource ID of the container registry.')
output containerRegistryId string = supportingServices.outputs.containerRegistryId

@description('The name of the container registry.')
output containerRegistryName string = supportingServices.outputs.containerRegistryName

@description('The resource ID of the user assigned managed identity for the container registry to be able to pull images from it.')
output containerRegistryUserAssignedIdentityId string = supportingServices.outputs.containerRegistryUserAssignedIdentityId

@description('The resource ID of the key vault.')
output keyVaultId string = supportingServices.outputs.keyVaultId

@description('The name of the key vault.')
output keyVaultName string = supportingServices.outputs.keyVaultName

@description('The resource ID of the user assigned managed identity to access the key vault.')
output keyVaultUserAssignedIdentityId string = supportingServices.outputs.keyVaultUserAssignedIdentityId

// Container Apps Environment
@description('The resource ID of the container apps environment.')
output containerAppsEnvironmentId string = containerAppsEnvironment.outputs.containerAppsEnvironmentId

@description('The name of the container apps environment.')
output containerAppsEnvironmentName string = containerAppsEnvironment.outputs.containerAppsEnvironmentName
