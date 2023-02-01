targetScope = 'subscription'

// Parameters
param spokergName string
param vnetSpokeName string
param spokeVNETaddPrefixes array
param spokeSubnets array
param vnetHubName string
param vnetHUBRGName string
param nsgACAName string
//param dhcpOptions object
param location string = deployment().location
var privateEndpointSubnetName = 'servicespe'


module rg 'modules/resource-group/rg.bicep' = {
  name: spokergName
  params: {
    rgName: spokergName
    location: location
  }
}

module vnetspoke 'modules/vnet/vnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: vnetSpokeName
  params: {
    location: location
    vnetAddressSpace: {
      addressPrefixes: spokeVNETaddPrefixes
    }
    vnetName: vnetSpokeName
    subnets: spokeSubnets
   // dhcpOptions: dhcpOptions
  }
  dependsOn: [
    rg
  ]
}

module nsgacasubnet 'modules/vnet/acansg.bicep' = {
  scope: resourceGroup(rg.name)
  name: nsgACAName
  params: {
    location: location
    nsgName: nsgACAName
  }
}

module nsggwsubnet 'modules/vnet/appgwnsg.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'nsggwsubnet'
  params: {
    location: location
  }
}


resource vnethub 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  scope: resourceGroup(vnetHUBRGName)
  name: vnetHubName
}

module vnetpeeringhub 'modules/vnet/vnetpeering.bicep' = {
  scope: resourceGroup(vnetHUBRGName)
  name: 'vnetpeeringhub'
  params: {
    peeringName: 'HUB-to-Spoke'
    vnetName: vnethub.name
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnetspoke.outputs.vnetId
      }
    }
  }
  dependsOn: [
    vnethub
    vnetspoke
  ]
}

module vnetpeeringspoke 'modules/vnet/vnetpeering.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vnetpeeringspoke'
  params: {
    peeringName: 'Spoke-to-HUB'
    vnetName: vnetspoke.outputs.vnetName
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnethub.id
      }
    }
  }
  dependsOn: [
    vnethub
    vnetspoke
  ]
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  // name: privateEndpointSubnetName
   name: '${spokergName}/${privateEndpointSubnetName}'
  scope: resourceGroup(subscription().subscriptionId, spokergName)
 }

 module privatednsACRZone 'modules/vnet/privatednszone.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privatednsACRZone'
  params: {
    privateDNSZoneName: 'privatelink.azurecr.io'
  }
}

module privateDNSLinkACR 'modules/vnet/privatednslink.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privateDNSLinkACR'
  params: {
    privateDnsZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetId: vnethub.id
    linkname: 'hub'
  }
}

module privateDNSLinkACRspoke 'modules/vnet/privatednslink.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privateDNSLinkACRspoke'
  params: {
    privateDnsZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'spoke'
  }
 
}

module privatednsVaultZone 'modules/vnet/privatednszone.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privatednsVaultZone'
  params: {
    privateDNSZoneName: 'privatelink.vaultcore.azure.net'
  }
}

module privateDNSLinkVault 'modules/vnet/privatednslink.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privateDNSLinkVault'
  params: {
    privateDnsZoneName: privatednsVaultZone.outputs.privateDNSZoneName
    vnetId: vnethub.id
    linkname: 'hub'
  }
}

module privateDNSLinkVaultspoke 'modules/vnet/privatednslink.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'privateDNSLinkVaultspoke'
  params: {
    privateDnsZoneName: privatednsVaultZone.outputs.privateDNSZoneName
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'spoke'
  }

}
