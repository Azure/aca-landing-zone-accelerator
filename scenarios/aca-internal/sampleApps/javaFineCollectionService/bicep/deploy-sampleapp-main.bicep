@description('The name of the log analytics workspace.')
param logAnalyticsWorkspaceName string

@description('The name of the spoke vnet')
param vnetName  string

@description('The name of the private endpoints services subnet')
param subnetName string

@description('The name of the aca deployed in the spoke vnet')
param containerAppsEnvironmentName string

@description('The name of provisioned azure container registry')
param acrName string

@description('The name of provisioned keyvault istance')
param keyVaultName string

@description('The user assigned identity name for ACA environmen')
param acaIdentityName string

//should be a var instead of a param. 
param location string = resourceGroup().location

#disable-next-line explicit-values-for-loc-params
module serviceBus 'resources/service-bus.bicep' = {
  name: 'serviceBusDeployment'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    acaIdentityName: acaIdentityName
    location:location
  }
}

#disable-next-line explicit-values-for-loc-params
module cosmosDB 'resources/cosmosdb.bicep' = {
  name: 'cosmosdbDeployment'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    acaIdentityName: acaIdentityName
    location:location
  }
}


module daprComponents 'resources/aca-dapr.bicep' = {
  name: 'acaDaprDeployment'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironmentName
    acaIdentityName: acaIdentityName
    serviceBusName: serviceBus.outputs.name
    cosmosDbName: cosmosDB.outputs.accountName
    cosmosDbDatabaseName: cosmosDB.outputs.databaseName
    cosmosDbCollectionName: cosmosDB.outputs.collectionName
    keyVaultName:keyVaultName
    location:location
  }
}

#disable-next-line explicit-values-for-loc-params
module acaApps 'resources/aca-apps.bicep' = {
  name: 'acaAppsDeployment'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironmentName
    acaIdentityName: acaIdentityName
    acrName: acrName
    location:location
  }
}
