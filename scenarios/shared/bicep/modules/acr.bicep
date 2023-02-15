// TODO: Clean up un nescessary elements, unexed etc. Check what is neeed for Role Assignments

@description('Required. Name of your Azure container registry. Needs to be globally unique. (may contain alpha numeric characters only and must be between 5 and 50 characters)')
@minLength(5)
@maxLength(50)
param name string

@description('Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Enable admin user that have push / pull permission to the registry.')
param adminUserEnabled bool = false

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Mandatory. Tier of your Azure container registry.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param acrSku string

@allowed([
  'disabled'
  'enabled'
])
@description('Optional. The value that indicates whether the export policy is enabled or not.')
param exportPolicyStatus string = 'disabled'

@allowed([
  'disabled'
  'enabled'
])
@description('Optional. The value that indicates whether the quarantine policy is enabled or not.')
param quarantinePolicyStatus string = 'disabled'

@allowed([
  'disabled'
  'enabled'
])
@description('Optional. The value that indicates whether the trust policy is enabled or not.')
param trustPolicyStatus string = 'disabled'

@allowed([
  'disabled'
  'enabled'
])
@description('Optional. The value that indicates whether the retention policy is enabled or not.')
param retentionPolicyStatus string = 'enabled'

@description('Optional. The number of days to retain an untagged manifest after which it gets purged.')
param retentionPolicyDays int = 15

@description('Optional. Enable a single data endpoint per region for serving data. Not relevant in case of disabled public access. Note, requires the \'acrSku\' to be \'Premium\'.')
param dataEndpointEnabled bool = false

@description('Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkRuleSetIpRules are not set.  Note, requires the \'acrSku\' to be \'Premium\'.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@allowed([
  'AzureServices'
  'None'
])
@description('Optional. Whether to allow trusted Azure services to access a network restricted registry.')
param networkRuleBypassOptions string = 'AzureServices'

@allowed([
  'Allow'
  'Deny'
])
@description('Optional. The default action of allow or deny when no other rules match.')
param networkRuleSetDefaultAction string = 'Deny'

@description('Optional. The IP ACL rules. Note, requires the \'acrSku\' to be \'Premium\'.')
param networkRuleSetIpRules array = []

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. Note, requires the \'acrSku\' to be \'Premium\'.')
param privateEndpoints array = []

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether or not zone redundancy is enabled for this container registry.')
param zoneRedundancy string = 'Disabled'


@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null


resource registry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: name
  location: location
  identity: identity
  tags: tags
  sku: {
    name: acrSku
  }
  properties: {    
    adminUserEnabled: adminUserEnabled
    policies: {      
      exportPolicy: acrSku == 'Premium' ? {
        status: exportPolicyStatus
      } : null
      quarantinePolicy: {
        status: quarantinePolicyStatus
      }
      trustPolicy: {
        type: 'Notary'
        status: trustPolicyStatus
      }
      retentionPolicy: acrSku == 'Premium' ? {
        days: retentionPolicyDays
        status: retentionPolicyStatus
      } : null
    }
    dataEndpointEnabled: dataEndpointEnabled
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : (!empty(privateEndpoints) && empty(networkRuleSetIpRules) ? 'Disabled' : null)
    networkRuleBypassOptions: networkRuleBypassOptions
    networkRuleSet: !empty(networkRuleSetIpRules) ? {
      defaultAction: networkRuleSetDefaultAction
      ipRules: networkRuleSetIpRules
    } : null
    zoneRedundancy: acrSku == 'Premium' ? zoneRedundancy : null
  }
}

// module registry_roleAssignments '.bicep/nested_roleAssignments.bicep' = [for (roleAssignment, index) in roleAssignments: {
//   name: '${uniqueString(deployment().name, location)}-ContainerRegistry-Rbac-${index}'
//   params: {
//     description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
//     principalIds: roleAssignment.principalIds
//     principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
//     roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
//     condition: contains(roleAssignment, 'condition') ? roleAssignment.condition : ''
//     delegatedManagedIdentityResourceId: contains(roleAssignment, 'delegatedManagedIdentityResourceId') ? roleAssignment.delegatedManagedIdentityResourceId : ''
//     resourceId: registry.id
//   }
// }]

// module registry_privateEndpoints '../../Microsoft.Network/privateEndpoints/deploy.bicep' = [for (privateEndpoint, index) in privateEndpoints: {
//   name: '${uniqueString(deployment().name, location)}-ContainerRegistry-PrivateEndpoint-${index}'
//   params: {
//     groupIds: [
//       privateEndpoint.service
//     ]
//     name: contains(privateEndpoint, 'name') ? privateEndpoint.name : 'pe-${last(split(registry.id, '/'))}-${privateEndpoint.service}-${index}'
//     serviceResourceId: registry.id
//     subnetResourceId: privateEndpoint.subnetResourceId
//     enableDefaultTelemetry: enableReferencedModulesTelemetry
//     location: reference(split(privateEndpoint.subnetResourceId, '/subnets/')[0], '2020-06-01', 'Full').location
//     lock: contains(privateEndpoint, 'lock') ? privateEndpoint.lock : lock
//     privateDnsZoneGroup: contains(privateEndpoint, 'privateDnsZoneGroup') ? privateEndpoint.privateDnsZoneGroup : {}
//     roleAssignments: contains(privateEndpoint, 'roleAssignments') ? privateEndpoint.roleAssignments : []
//     tags: contains(privateEndpoint, 'tags') ? privateEndpoint.tags : {}
//     manualPrivateLinkServiceConnections: contains(privateEndpoint, 'manualPrivateLinkServiceConnections') ? privateEndpoint.manualPrivateLinkServiceConnections : []
//     customDnsConfigs: contains(privateEndpoint, 'customDnsConfigs') ? privateEndpoint.customDnsConfigs : []
//     ipConfigurations: contains(privateEndpoint, 'ipConfigurations') ? privateEndpoint.ipConfigurations : []
//     applicationSecurityGroups: contains(privateEndpoint, 'applicationSecurityGroups') ? privateEndpoint.applicationSecurityGroups : []
//     customNetworkInterfaceName: contains(privateEndpoint, 'customNetworkInterfaceName') ? privateEndpoint.customNetworkInterfaceName : ''
//   }
// }]

@description('The Name of the Azure container registry.')
output acrName string = registry.name

@description('The reference to the Azure container registry.')
output loginServer string = reference(registry.id, '2019-05-01').loginServer

@description('The resource ID of the Azure container registry.')
output acrResourceId string = registry.id

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(registry.identity, 'principalId') ? registry.identity.principalId : ''
