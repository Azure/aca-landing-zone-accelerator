param workspaceName string
param location string = resourceGroup().location

resource logworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: workspaceName
  location: location
  properties: any({
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  })
}



output laworkspaceId string = logworkspace.id
var clientsec = listKeys(logworkspace.id, '2021-06-01').primarySharedKey
output clientId string = logworkspace.properties.customerId
output clientSecret string = clientsec
