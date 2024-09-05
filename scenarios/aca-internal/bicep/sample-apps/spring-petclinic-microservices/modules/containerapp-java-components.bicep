param managedEnvironmentsName string
param configServerGitRepo string
param configServerGitBranch string

resource managedEnvironmentsResource 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: managedEnvironmentsName
}

resource configServer 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironmentsResource
  name: 'configserver'
  properties: {
    componentType: 'SpringCloudConfig'
    configurations: [
      {
        propertyName: 'spring.cloud.config.server.git.uri'
        value: configServerGitRepo
      }
      {
        propertyName: 'spring.cloud.config.server.git.default-label'
        value: configServerGitBranch
      }
    ]
  }
}

resource eureka 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironmentsResource
  name: 'eureka'
  properties: {
    componentType: 'SpringCloudEureka'
  }
}

output eurekaId string = eureka.id
output configServerId string = configServer.id
