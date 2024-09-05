# Deploy the Container Apps

Once the Azure Container Apps created and connect to the database, we can go to deploy the Spring Boot application to the created apps. Every time you modify the application code, you can rerun the steps in this tutorial to deploy the changes.

## Expected results
This documentation guides how to deploy the PetClinic microservices.

## Resources

- PetClinic microservices images
- Deploy images to containr apps

## Steps


1. Retrieve the Networking and Azure Container Registry information from previous deployment.

    ```bash
    RESOURCENAME_RESOURCEGROUP_SPOKE=$(az deployment sub show -n acalza01-spokenetwork --query properties.outputs.spokeResourceGroupName.value -o tsv)
    ENVIRONMENT_NAME=$(az deployment group show -n acalza01-appplat -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerAppsEnvironmentName.value -o tsv)
    RESOURCEID_IDENTITY_ACR=$(az deployment group show -n acalza01-dependencies -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerRegistryUserAssignedIdentityId.value -o tsv)
    REGISTRYNAME_ACR=$(az deployment group show -n acalza01-dependencies -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerRegistryName.value -o tsv)
    LOGINSERVER_ACR=$(az deployment group show -n acalza01-dependencies -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerRegistryLoginServer.value -o tsv)
    RESOURCEID_EUREKA=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.eurekaId.value -o tsv)    
    RESOURCEID_CONFIGSERVER=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.configServerId.value -o tsv)
    RESOURCEID_MYSQL_DATABASE=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.databaseId.value -o tsv)
    RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.userAssignedIdentityClientId.value -o tsv)

    echo RESOURCENAME_RESOURCEGROUP_SPOKE: $RESOURCENAME_RESOURCEGROUP_SPOKE && \
    echo ENVIRONMENT_NAME: $ENVIRONMENT_NAME && \
    echo RESOURCEID_IDENTITY_ACR: $RESOURCEID_IDENTITY_ACR && \
    echo REGISTRYNAME_ACR: $REGISTRYNAME_ACR && \
    echo LOGINSERVER_ACR: $LOGINSERVER_ACR && \
    echo RESOURCEID_MYSQL_DATABASE: $RESOURCEID_MYSQL_DATABASE && \
    echo RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID: $RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID && \
    echo RESOURCEID_EUREKA: $RESOURCEID_EUREKA && \
    echo RESOURCEID_CONFIGSERVER: $RESOURCEID_CONFIGSERVER
    ```

1. Go to source code folder and compile the code.

   ```bash
   cd src
   mvn clean package -DskipTests
   cd ..
   ```

1. Build the docker image by using Azure Container Registry Build. Each line may cost around 1 minute.

   ```bash
   IMAGE_TAG=3.0.1-$(date -u +%Y%m%d%H%M%S)

    az acr build -t spring-petclinic-vets-service:${IMAGE_TAG} -r ${REGISTRYNAME_ACR} src/spring-petclinic-vets-service/target/docker --build-arg ARTIFACT_NAME=vets-service-3.0.1 --build-arg  EXPOSED_PORT=8080
    az acr build -t spring-petclinic-visits-service:${IMAGE_TAG} -r ${REGISTRYNAME_ACR} src/spring-petclinic-visits-service/target/docker --build-arg ARTIFACT_NAME=visits-service-3.0.1 --build-arg  EXPOSED_PORT=8080
    az acr build -t spring-petclinic-customers-service:${IMAGE_TAG} -r ${REGISTRYNAME_ACR} src/spring-petclinic-customers-service/target/docker --build-arg ARTIFACT_NAME=customers-service-3.0.1 --build-arg  EXPOSED_PORT=8080
    az acr build -t spring-petclinic-api-gateway:${IMAGE_TAG} -r ${REGISTRYNAME_ACR} src/spring-petclinic-api-gateway/target/docker --build-arg ARTIFACT_NAME=api-gateway-3.0.1 --build-arg  EXPOSED_PORT=8080
   ```

1. Deploy the microservices to Azure Container Apps

   ```bash
    az deployment group create -n acalza01-appplat-microservices -g $RESOURCENAME_RESOURCEGROUP_SPOKE \
        -f modules/petclinic.bicep \
        -p managedEnvironmentsName=${ENVIRONMENT_NAME} \
        -p eurekaId=${RESOURCEID_EUREKA} \
        -p configServerId=${RESOURCEID_CONFIGSERVER} \
        -p mysqlDBId=${RESOURCEID_MYSQL_DATABASE} \
        -p mysqlUserAssignedIdentityClientId=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID} \
        -p acrRegistry=${LOGINSERVER_ACR} \
        -p imageTag=${IMAGE_TAG} \
        -p acrIdentityId=${RESOURCEID_IDENTITY_ACR}
   ```

## Verification

1. Get the public IP of Application Gateway.

   ```bash
   IP_APPGW=$(az deployment group show -g rg-lzaaca-spoke-dev-eus2 -n acalza01-appgw --query properties.outputs.applicationGatewayPublicIp.value -o tsv)
   echo $IP_APPGW
   ```

1. View the https://$IP_APPGW in browser.
