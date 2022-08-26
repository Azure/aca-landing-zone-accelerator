param location string = resourceGroup().location
param name string
var roleDefinitionResourceId = '/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'



resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, 'managedIdentity.id', roleDefinitionResourceId)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: managedIdentity.properties.principalId
   // principalId: '/subscriptions/0f629d89-46bc-474b-941a-c7140441a426/resourcegroups/srtestaca12/providers/Microsoft.ManagedIdentity/userAssignedIdentities/acasrtestid'
    principalType: 'ServicePrincipal'
  }
}
output msiid string = managedIdentity.properties.principalId
output msirid string = managedIdentity.id
