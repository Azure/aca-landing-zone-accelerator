# Proposal for Spring Petclinic Microservices Folder

This folder will contain the Spring Boot microservices implementation of the [Petclinic application](https://github.com/Azure-Samples/spring-petclinic-microservices). The folder will consist of four microservices that work together to provide the functionality of the application.

## `src`
The `src` directory will contain the source code of the PetClinic application. It is a Maven project that customers can build and verify in their local environment. This directory will include all the Java files, configuration files, and resources required for the application. Customers can make modifications or enhancements to the codebase as needed before deploying the microservices.
The microservices will have:
- spring-petclinic-api-gateway
- spring-petclinic-customers-service
- spring-petclinic-vets-service
- spring-petclinic-visits-service

## `docs`
Describes what is the application and the code layout.

## `modules` and `main.bicep`

### VNet environment
It is going to leverage the existing instructions to create the necessary infrastructure components, such as the VNet environment, hub, spoke, and container app environments. These infrastructure components will be essential for deploying and running the microservices.

### Supporting service
It will creates a mysql database for the application as a supporting  service. I will put this module into [03-supporting-services](../../modules/03-supporting-services).

### Java components as supporting parts
Additionally, the proposal includes the creation of Container App Java components that will be used by the microservices. These components will provide the necessary functionality and dependencies required by the microservices to run successfully. These components are:
- [Eureka Server](https://learn.microsoft.com/en-us/azure/container-apps/java-eureka-server-usage)
- [Config Server](https://learn.microsoft.com/en-us/azure/container-apps/java-config-server-usage)


### Applications
The bicep will create ACA app for each microservice, and connect it to the mysql and Java components.

