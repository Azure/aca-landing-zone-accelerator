// ------------------
//    PARAMETERS
// ------------------

@description('Name of the Network Security Group. Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. ')
@maxLength(80)
param name string

@description('Azure Region where the resource will be deployed in')
param location string

@description('key-value pairs as tags, to identify the resource')
param tags object

@description('An array of network security rules. ')
param securityRules array

// ------------------
// VARIABLES
// ------------------



// ------------------
// RESOURCES
// ------------------

// TODO: do we need flowlogs? https://learn.microsoft.com/azure/network-watcher/quickstart-configure-network-security-group-flow-logs-from-bicep?tabs=CLI

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}


// ------------------
// OUTPUTS
// ------------------

@description('Resource id of the newly created Network Security Group')
output nsgId string = nsg.id

@description('Resource name of the newly created Network Security Group')
output nsgName string = nsg.name
