param name string
param location string = resourceGroup().location
param lawClientId string

@secure()
param lawClientSecret string

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
    zoneRedundant: false
  }
}

output envid string = environment.id
