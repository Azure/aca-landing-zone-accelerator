targetScope = 'subscription'

// ================ //
// Parameters       //
// ================ //

@description('Azure region where the resources will be deployed in')
param location string

@description('Required. The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param hubVnetAddressSpace string

@description('Optional. A numeric suffix (e.g. "001") to be appended on the naming generated for the resources. Defaults to empty.')
param numericSuffix string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param resourceTags object = {}

@description('mandatory, the password of the admin user')
@secure()
param vmWinJumpboxHubAdminPassword string


// ================ //
// Variables        //
// ================ //

var tags = union({
  environment: environment
}, resourceTags)

var resourceSuffix = '${environment}-${location}'
var hubResourceGroupName = 'rg-hub-${resourceSuffix}'

var defaultSuffixes = [
  environment
  '**location**'
]
var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [
  numericSuffix
])


// ================ //
// Resources        //
// ================ //

// TODO: Must be shared among diferrent scenarios: Change in ASE (tt20230129)
module naming '../modules/naming.module.bicep' = {
  scope: resourceGroup(hubResourceGroup.name)
  name: 'namingModule-Deployment'
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}


//TODO: hub must be optional to create - might already exist and we need to attach to - might be in different subscription (tt20230129)
resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: hubResourceGroupName
  location: location
  tags: tags
}

//TODO: Needs to be optional (tt20230212)
module hub 'hub.deployment.bicep' = {
  scope: resourceGroup(hubResourceGroup.name)
  name: 'hubDeployment'
  params: {
    naming: naming.outputs.names
    location: location
    hubVnetAddressSpace: hubVnetAddressSpace
    tags: tags
    vmWinJumpboxHubAdminPassword: vmWinJumpboxHubAdminPassword
  }
}
