
param location string = resourceGroup().location
@description('The FQDN for the Application Gateway. Example - api.contoso.com.')
param appGatewayFqdn string 
param appGatewayName string 
@description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
@secure()
param certificatePassword string 
param containerAppName string
param keyvaultName string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string
param spokeRgName string 
var GWVNetSubnetName = 'appGatewaySubnetName'
param vnetSpokeName string

resource subnetAppGW 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  // scope: resourceGroup(rgName)
   name: '${vnetSpokeName}/${GWVNetSubnetName}'
 }

 resource containerApp 'Microsoft.App/containerApps@2022-03-01' existing = {
  name: containerAppName
 }



module appgwModule './modules/appgw/appgw.bicep' = {
  name: 'appgwDeploy'
  //scope: rgName
  dependsOn: [
  ]
  params: {
    appGatewayName:                 appGatewayName
    appGatewayFQDN:                 appGatewayFqdn
    location:                       location
    appGatewaySubnetId:             subnetAppGW.id
    primaryBackendEndFQDN:          containerApp.properties.configuration.ingress.fqdn
    keyVaultName:                   keyvaultName
    keyVaultResourceGroupName:      spokeRgName
    appGatewayCertType:             appGatewayCertType
    certPassword:                   certificatePassword
  }
}


