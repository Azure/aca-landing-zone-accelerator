
param location string = resourceGroup().location
@description('The FQDN for the Application Gateway. Example - api.contoso.com.')
param appGatewayFqdn string = 'api.contoso.com'
param appGatewayName string = 'srtestgwbicep'
@description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
@secure()
param certificatePassword string 

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string = 'selfsigned'
param rgName string = 'ESLZ-SPOKE2'
var GWVNetSubnetName = 'appGatewaySubnetName'
var spokeVnetName = 'VNet-SPOKE'
resource subnetAppGW 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  // scope: resourceGroup(rgName)
   name: '${spokeVnetName}/${GWVNetSubnetName}'
 }

module appgwModule 'appgw.bicep' = {
  name: 'appgwDeploy'
  //scope: rgName
  dependsOn: [
  ]
  params: {
    appGatewayName:                 appGatewayName
    appGatewayFQDN:                 appGatewayFqdn
    location:                       location
    appGatewaySubnetId:             subnetAppGW.id
    primaryBackendEndFQDN:          'acatestbicep.calmglacier-25f5dbad.eastus.azurecontainerapps.io'
    keyVaultName:                   'eslz-kv-gtf5q2jnnj7jw'
    keyVaultResourceGroupName:      rgName
    appGatewayCertType:             appGatewayCertType
    certPassword:                   certificatePassword
  }
}


