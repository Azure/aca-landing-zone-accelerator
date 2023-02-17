targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param hubVnetAddressSpace string

@description('mandatory, the password of the admin user')
@secure()
param vmWinJumpboxHubAdminPassword string



var resourceNames = {
  // TODO Clean Up comments(tt20230214) 
  bastionService: naming.bastionHost.name
  vnetHub: '${naming.virtualNetwork.name}-hub'
  vmWindowsJumpbox: '${naming.windowsVirtualMachine.name}-win-jumpbox'
}

var subnetInfo = loadJsonContent('configuration/hub-vnet-snet-config.jsonc')

var hubVnetSubnets = [for item in subnetInfo.subnets: {
  name: item.name
  properties: {
    addressPrefix: item.addressPrefix
    privateEndpointNetworkPolicies: item.privateEndpointNetworkPolicies =~ 'Disabled' ? 'Disabled' : 'Enabled'
  }
}]

module vnetHub '../modules/network/vnet.bicep' = {
  name: 'vnetHubDeployment'
  params: {
    location: location
    name: resourceNames.vnetHub
    subnetsInfo: hubVnetSubnets
    tags: tags
    vnetAddressSpace:  hubVnetAddressSpace
  }
}

resource snetCompute 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetHub.outputs.vnetName}/${subnetInfo.subnetCompute}'
}

module bastionSvc '../modules/network/bastion.bicep' = {
  name: 'bastionSvcDeployment'
  params: {
    location: location
    name: resourceNames.bastionService
    vnetId: vnetHub.outputs.vnetId
    tags: tags
  }
}

module winVM '../modules/compute/jumphost-win10.bicep' = {
  name: 'windowsJumphostDeployment'
  params: {
    location: location
    name: resourceNames.vmWindowsJumpbox
    subnetId: snetCompute.id
    tags: tags
    adminPassword: vmWinJumpboxHubAdminPassword
    computerWindowsName: 'winHubJumpbox01'
  }
}
