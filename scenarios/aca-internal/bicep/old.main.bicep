targetScope = 'subscription'
@description('Name of the Resource group in which the hub resources will be deployed.')
param hubRgName string
@description('Name of the Hub Virtual Network to be created.')
param vnetHubName string
@description('CIDR of the Hub Virtual Network.')
param hubVnetAddressPrefix array
@description('Hub subnets to created.')
param hubSubnets array

@description('Azure location to which the resources are to be deployed')
param location string = deployment().location
//param deployFW bool
@description('Select this parameter to be true if you need bastion to be deployed.')
param deployBastion bool
@description('Select OS of the jumpbox VM.It can be linux or windows ostype for the jumpbox')
@allowed([
  'linux'
  'windows'
])
param jumpboxOsType string = 'linux'
@description('Name of the subnet in which your jumpbox VM will be deployed.')
param vmSubnetName string
@description('Address Prefix of the bastion subnet in which your bastion will be deployed.')
param bastionSubnetAddressPrefix string
param publicKeyData string
@description('Valid SKU indicator for the VM')
param vmSize string
@description('The user name to be used as the Administrator for all VMs created by this deployment')
param adminUsername string
@description('The password for the Administrator user for all VMs created by this deployment')
param adminPassword string

@description('Name of the Resource group in which the spoke resources will be deployed.')
param spokeRgName string
@description('Name of the Spoke Virtual Network to be created.')
param vnetSpokeName string
@description('CIDR of the Spoke Virtual Network.')
param spokeVnetAddressPrefix array
@description('Soke subnets to created.')
param spokeSubnets array
@description('Name of the Network Security group for the subnet in which container app environment will be injected.')
param nsgAcaName string

@description('Select this parameter to be true if you need appinsights to be deployed.')
param deployApplicationInsightsDaprInstrumentation bool
@description('Name of the subnet in which your container apps will be injected.')
param acaSubnetName string
@description('Name of the subnet in which application gateway will be injected.')
var gwSubnetName = 'appGatewaySubnetName'

@description('Name of the Private Endpoint for your KeyVault.')
param keyVaultPrivateEndpointName string
@description('Name of the Private Endpoint for your container registry.')
param acrPrivateEndpointName string

param privateDnsZoneAcrName string
param privateDnsZoneKvName string
param acrName string = 'eslzacr${uniqueString('acrvws',utcNow('u'))}'
param keyvaultName string = 'eslz-kv-${uniqueString('acrvws',utcNow('u'))}'
param appInsightsName string


//var acrName = 'eslzacr${uniqueString(spokergName, deployment().name)}'
//var keyvaultName = 'eslz-kv-${uniqueString(spokergName, deployment().name)}'



param containerEnvName string

param acaLaWorkspaceName string
param peSubnetName string
param acaIdentityName string

param containerAppName string



// // Deploy Hub Network

// //Create Hub Resource Group
// module hubrg '../../shared/bicep/resource-group/rg.bicep' = {
//   name: hubRgName
//   params: {
//     rgName: hubRgName
//     location: location
//   }
// }

// //Create Hub Vnet
// module vnethub '../../shared/bicep/vnet/vnet.bicep' = {
//   scope: resourceGroup(hubrg.name)
//   name: vnetHubName
//   params: {
//     location: location
//     vnetAddressSpace: {
//         addressPrefixes: hubVnetAddressPrefix
//     }
//     vnetName: vnetHubName
//     subnets: hubSubnets
//   }
//   dependsOn: [
//     hubrg
//   ]
// }

// //module ddd '../../shared/bicep/vnet/vnet.bicep'

// // Create public IP for bastion. It will be created only if you want to deploy bastion.
// module publicipbastion '../../shared/bicep/vm/public-ip.bicep' = if (deployBastion) {
//   scope: resourceGroup(hubrg.name)
//   name: 'publicipbastion'
//   params: {
//     location: location
//     publicipName: 'bastion-pip'
//     deploybastion: deployBastion
//     publicipproperties: {
//       publicIPAllocationMethod: 'Static'
//     }
//     publicipsku: {
//       name: 'Standard'
//       tier: 'Regional'
//     }
//   }
// }


// resource subnetbastion 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = if (deployBastion) {
//   scope: resourceGroup(hubrg.name)
//   name: '${vnetHubName}/AzureBastionSubnet'
// }

// //Create Bastion Resource
// module bastion '../../shared/bicep/vm/bastion.bicep' = if (deployBastion) {
//   scope: resourceGroup(hubrg.name)
//   name: 'bastion'
//   params: {
//     location: location
//     bastionpipId: publicipbastion.outputs.publicipId
//     subnetId: subnetbastion.id
//     deploybastion: deployBastion
//     bastionAddressPrefix: bastionSubnetAddressPrefix
//     vnetHubName: vnetHubName
//   }
//   dependsOn: [
//     hubrg
//     vnethub
//     jumpbox
//   ]
// }




// Deploy Virtual Machine in Hub (linux or Windows)

// TODO: Do we need choosing windows or linux? 

module jumpbox '../../shared/bicep/vm/virtual-machine.bicep' = if (jumpboxOsType == 'linux') {
  scope: resourceGroup(hubrg.name)
  name: 'jumpbox'
  params: {
    location: location
    publicKey: publicKeyData
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    osType: jumpboxOsType
    vnetHubName: vnetHubName
    VMSubnetName: vmSubnetName
  }
  dependsOn: [
    hubrg
    vnethub
  ]
}

// module vm_jumpboxwinvm '../../shared/bicep/vm/create-vm-windows.bicep' = if (jumpboxOsType == 'windows') {
//   name: 'vm-jumpbox'
//   scope: resourceGroup(hubrg.name)
//   params: {
//     location: location
//     username: adminUsername
//     password: adminPassword
//     CICDAgentType: 'none'
//     vmName: 'jumpbox'
//     osType: jumpboxOsType
//     vnetHubName: vnetHubName
//     VMSubnetName: vmSubnetName
//   }
//   dependsOn: [
//     hubrg
//     vnethub
//     bastion
//   ]
// }



// Deploy Spoke Network


//DONE
module spokerg '../../shared/bicep/resource-group/rg.bicep' = {
  name: spokeRgName
  params: {
    rgName: spokeRgName
    location: location
  }
}

//DONE
module vnetspoke '../../shared/bicep/vnet/vnet.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: vnetSpokeName
  params: {
    location: location
    vnetAddressSpace: {
      addressPrefixes: spokeVnetAddressPrefix
    }
    vnetName: vnetSpokeName
    subnets: spokeSubnets
   // dhcpOptions: dhcpOptions
  }
  dependsOn: [
    spokerg
  ]
}



// Hub OK. done up to here tt20230214
// SPOKE RG-VNET-SUBNETS Initial config OK
// TODO: Lines 230 to 400 need to be done in the future

module nsgacasubnet '../../shared/bicep/vnet/aca-nsg.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: nsgAcaName
  params: {
    location: location
    nsgName: nsgAcaName
  }
}

module nsggwsubnet '../../shared/bicep/vnet/app-gw-nsg.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'nsggwsubnet'
  params: {
    location: location
  }
}


module vnetpeeringhub '../../shared/bicep/vnet/vnet-peering.bicep' = {
  scope: resourceGroup(hubrg.name)
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

module vnetpeeringspoke '../../shared/bicep/vnet/vnet-peering.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'vnetpeeringspoke'
  params: {
    peeringName: 'Spoke-to-HUB'
    vnetName: vnetspoke.outputs.vnetName
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnethub.outputs.vnetId
      }
    }
  }
  dependsOn: [
    vnethub
    vnetspoke
  ]
}


//done
 module privatednsACRZone '../../shared/bicep/vnet/private-dns-zone.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privatednsACRZone'
  params: {
    privateDNSZoneName: 'privatelink.azurecr.io'
  }
}

//done
module privateDNSLinkACR '../../shared/bicep/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACR'
  params: {
    privateDnsZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetId: vnethub.outputs.vnetId
    linkname: 'hub'
  }
}

//done
module privateDNSLinkACRspoke '../../shared/bicep/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACRspoke'
  params: {
    privateDnsZoneName: privatednsACRZone.outputs.privateDNSZoneName
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'spoke'
  }
 
}

//done
module privatednsVaultZone '../../shared/bicep/vnet/private-dns-zone.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privatednsVaultZone'
  params: {
    privateDNSZoneName: 'privatelink.vaultcore.azure.net'
  }
}

//done
module privateDNSLinkVault '../../shared/bicep/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkVault'
  params: {
    privateDnsZoneName: privatednsVaultZone.outputs.privateDNSZoneName
    vnetId: vnethub.outputs.vnetId
    linkname: 'hub'
  }
}

//done
module privateDNSLinkVaultspoke '../../shared/bicep/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkVaultspoke'
  params: {
    privateDnsZoneName: privatednsVaultZone.outputs.privateDNSZoneName
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'spoke'
  }

}



module updateACANSG '../../shared/bicep/vnet/subnet.bicep' = {
scope: resourceGroup(spokerg.name)
  name: 'updateNSG'
  params: {
    subnetName: acaSubnetName
    vnetName: vnetSpokeName
    properties: {
     addressPrefix: spokeSubnets[0].properties.addressPrefix
      networkSecurityGroup: {
        id: nsgacasubnet.outputs.nsgID
      }
    }
  }
  dependsOn: [  
    vnetspoke
    vnetpeeringhub
    vnetpeeringspoke
  ]
}



module updateGWNSG '../../shared/bicep/vnet/subnet.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'updateGWNSG'
  params: {
    subnetName: gwSubnetName
    vnetName: vnetSpokeName
    properties: {
      addressPrefix: spokeSubnets[2].properties.addressPrefix
      networkSecurityGroup: {
        id: nsggwsubnet.outputs.nsgID
      }
    }
  }
  dependsOn: [
    updateACANSG
    vnetspoke 
    vnetpeeringhub
    vnetpeeringspoke 
  ]
}





// Deploy supporting services
//done 
module acr '../../shared/bicep/acr/acr.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: acrName
  params: {
    location: location
    acrName: acrName
    acrSkuName: 'Premium'
  }
}

//done 
module keyvault '../../shared/bicep/keyvault/keyvault.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: keyvaultName
  params: {
    location: location
    keyVaultsku: 'Standard'
    name: keyvaultName
    tenantId: subscription().tenantId
  }
}

//done 
resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  scope: resourceGroup(spokerg.name)
  name: '${vnetSpokeName}/${peSubnetName}'
}

//done 
module privateEndpointKeyVault '../../shared/bicep/vnet/private-endpoint.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: keyVaultPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'Vault'
    ]
    privateEndpointName: keyVaultPrivateEndpointName
    privatelinkConnName: '${keyVaultPrivateEndpointName}-conn'
    resourceId: keyvault.outputs.keyvaultId
    subnetid: servicesSubnet.id
  }
}

//done 
module privateEndpointAcr '../../shared/bicep/vnet/private-endpoint.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: acrPrivateEndpointName
  params: {
    location: location
    groupIds: [
      'registry'
    ]
    privateEndpointName: acrPrivateEndpointName
    privatelinkConnName: '${acrPrivateEndpointName}-conn'
    resourceId: acr.outputs.acrid
    subnetid: servicesSubnet.id
  }
}


//done 
resource privateDNSZoneACR 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(spokerg.name)
  name: privateDnsZoneAcrName
}

//done 
module privateEndpointACRDNSSetting '../../shared/bicep/vnet/private-dns.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acr-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneACR.id
    privateEndpointName: privateEndpointAcr.name
  }
}

//done 
resource privateDNSZoneKV 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(spokerg.name)
  name: privateDnsZoneKvName
}

//done 
module privateEndpointKVDNSSetting '../../shared/bicep/vnet/private-dns.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'kv-pvtep-dns'
  params: {
    privateDNSZoneId: privateDNSZoneKV.id
    privateEndpointName: privateEndpointKeyVault.name
  }
}


//done
module acaIdentity '../../shared/bicep/identity/user-assigned.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acaIdentity'
  params: {
    location: location
    identityName: acaIdentityName
  }
}

output acrName string = acr.name
output keyvaultName string = keyvault.name



//Deploy Container App Environment



//done
module acalaworkspace '../../shared/bicep/laworkspace/la.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acalaworkspace'
  params: {
    location: location
    workspaceName: acaLaWorkspaceName
  }
}

//done
module acaApplicationInsights '../../shared/bicep/app-insights/ai.bicep' = if (deployApplicationInsightsDaprInstrumentation) {
  scope: resourceGroup(spokerg.name)
  name: 'acaAppInsights'
  params: {
    name: appInsightsName
    location: location
    laworkspaceId: acalaworkspace.outputs.laworkspaceId
  }
}

//done
module containerAppEnvironment '../../shared/bicep/aca/container-app-env.bicep' = {
  scope: resourceGroup(spokerg.name)
   name: 'ACA-env-Deploy'
    params: {
        name: containerEnvName
        location: location
        infrasubnet: '${vnetspoke.outputs.vnetId}/subnets/${acaSubnetName}'
        workspaceName: acaLaWorkspaceName
        applicationInsightsName: (deployApplicationInsightsDaprInstrumentation ?  acaApplicationInsights.outputs.appInsightsName : '')
       // runtimesubnet: spokenetwork.outputs.infrasubnet
    }
    dependsOn: [
      acalaworkspace
    ]
}


module acracaaccess '../../shared/bicep/identity/acr-role.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acracaaccess'
  params: {
    principalId: acaIdentity.outputs.principalId
    roleGuid: '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
    acrName: acrName
  }
  dependsOn: [
    acaIdentity
    acr
    containerAppEnvironment
  ]
}



module keyvaultAccessPolicy '../../shared/bicep/keyvault/keyvault-access.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'acakeyvaultaddonaccesspolicy'
  params: {
    keyvaultManagedIdentityObjectId: acaIdentity.outputs.principalId
    vaultName: keyvaultName
    acauseraccessprincipalId: acaIdentity.outputs.principalId
  }
}

//done
module acadnszone '../../shared/bicep/vnet/private-dns-zone.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privatednsACAZone'
  params: {
    privateDNSZoneName: containerAppEnvironment.outputs.envfqdn
  }
  
}

//done
module privateDNSLinkACAHub '../../shared/bicep/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACAHub'
  params: {
    privateDnsZoneName: containerAppEnvironment.outputs.envfqdn
    vnetId: vnethub.outputs.vnetId
    linkname: 'ACA-hub'
  }
  dependsOn: [
    acadnszone
  ]
}

//done
module privateDNSLinkACAspoke '../../shared/bicep/vnet/private-dns-link.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'privateDNSLinkACAspoke'
  params: {
    privateDnsZoneName: containerAppEnvironment.outputs.envfqdn
    vnetId: vnetspoke.outputs.vnetId
    linkname: 'ACA-spoke'
  }
  dependsOn: [
    acadnszone
  ]
}

//done
module record '../../shared/bicep/vnet/a-record.bicep' = {
  scope: resourceGroup(spokerg.name)
  name: 'recordNameArecord'
  params: {
    envstaticip: containerAppEnvironment.outputs.envip
    recordName: containerAppName
    privateDNSZoneName: containerAppEnvironment.outputs.envfqdn
  }
  dependsOn: [
    acadnszone
    containerAppEnvironment
  ]
}
