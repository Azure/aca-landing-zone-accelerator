param administratorLogin string
@secure()
param administratorLoginPassword string
param serverName string
param databaseName string
param version string
param mysqlSubnetPrefix string
param spokeVnetId string
param hubVnetId string
param subnetName string

param managedEnvironmentsName string
param configServerGitRepo string
param configServerGitBranch string

param acrIdentityId string
param acrRegistry string
param simpleHelloImage string
param simpleHelloTag string


module mysql 'modules/mysql.bicep' = {
  name: 'mysql'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    serverName: serverName
    databaseName: databaseName
    version: version
    spokeVnetId: spokeVnetId
    hubVnetId: hubVnetId
    subnetName: subnetName
    mysqlSubnetPrefix: mysqlSubnetPrefix
  }
}

module javaComponents 'modules/containerapp-java-components.bicep' = {
  name: 'javaComponents'
  params: {
    managedEnvironmentsName: managedEnvironmentsName
    configServerGitRepo: configServerGitRepo
    configServerGitBranch: configServerGitBranch
  }
}

module applications 'modules/petclinic.bicep' = {
  name: 'petclinic-microservices'
  params: {
    managedEnvironmentsName: managedEnvironmentsName
    eurekaId: javaComponents.outputs.eurekaId
    configServerId: javaComponents.outputs.configServerId
    mysqlDBId: mysql.outputs.databaseId
    mysqlUserAssignedIdentityClientId: mysql.outputs.userAssignedIdentityClientId
    acrRegistry: acrRegistry
    acrIdentityId: acrIdentityId
    imageTag: simpleHelloTag
    /* Set the first creation to hello world image */
    apiGatewayImage: simpleHelloImage
    customerServiceImage: simpleHelloImage
    vetsServiceImage: simpleHelloImage
    visitsServiceImage: simpleHelloImage
    targetPort: 80
  }
}

output fqdn string = applications.outputs.fqdn

output apiGatewayId string = applications.outputs.gatewayId
output customerServiceId string = applications.outputs.customerServiceId
output visitsServiceId string = applications.outputs.visitsServiceId
output vetsServiceId string = applications.outputs.vetsServiceId

output eurekaId string = javaComponents.outputs.eurekaId
output configServerId string = javaComponents.outputs.configServerId
output databaseId string = mysql.outputs.databaseId
output userAssignedIdentityClientId string = mysql.outputs.userAssignedIdentityClientId
output userAssignedIdentity string = mysql.outputs.userAssignedIdentity
