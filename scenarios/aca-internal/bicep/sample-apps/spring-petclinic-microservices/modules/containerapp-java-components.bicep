param managedEnvironments_name string

resource managedEnvironments_resource 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: managedEnvironments_name
}

resource configServer 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironments_resource
  name: 'configserver'
  properties: {
    componentType: 'SpringCloudConfig'
    configurations: [
      {
        propertyName: 'spring.cloud.config.server.git.uri'
        value: 'https://github.com/RuoyuWang-MS/spring-petclinic-microservices-config'
      }
      {
        propertyName: 'spring.cloud.config.server.git.default-label'
        value: 'main'
      }
    ]
  }
}

resource eureka 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironments_resource
  name: 'eureka'
  properties: {
    componentType: 'SpringCloudEureka'
  }
}

resource springbootadmin 'Microsoft.App/managedEnvironments/javaComponents@2024-02-02-preview' = {
  parent: managedEnvironments_resource
  name: 'springbootadmin'
  properties: {
    componentType: 'SpringBootAdmin'
  }
}

output eureka_id string = eureka.id
output configserver_id string = configServer.id
