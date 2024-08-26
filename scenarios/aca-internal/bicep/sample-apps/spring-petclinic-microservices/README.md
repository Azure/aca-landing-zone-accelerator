```
RESOURCENAME_RESOURCEGROUP_SPOKE=$(az deployment sub show -n acalza01-spokenetwork --query properties.outputs.spokeResourceGroupName.value -o tsv)
ENVIRONMENT_NAME=$(az deployment group show -n acalza01-appplat -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerAppsEnvironmentName.value -o tsv)

az deployment group create -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE    -f ../sample-apps/spring-petclinic-microservices/modules/containerapp-java-components.bicep -p managedEnvironments_name=${ENVIRONMENT_NAME}

EUREKA_ID=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.eureka_id.value -o tsv)    
CONFIGSERVER_ID=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.configserver_id.value -o tsv)
RESOURCEID_IDENTITY_ACR=$(az deployment group show -n acalza01-dependencies -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerRegistryUserAssignedIdentityId.value -o tsv)

az deployment group create -n acalza01-appplat-app -g $RESOURCENAME_RESOURCEGROUP_SPOKE    -f ../modules/petclinic.bicep  -p managedEnvironments_name=${ENVIRONMENT_NAME} eureka_id=${EUREKA_ID} configserver_id=${CONFIGSERVER_ID} acr_identity_id=${RESOURCEID_IDENTITY_ACR} image_tag=${IMAGE_TAG}

FQDN=$(az deployment group show -g $RESOURCENAME_RESOURCEGROUP_SPOKE -n acalza01-appplat-app --query properties.outputs.fqdn.value -o tsv)
```

```
IMAGE_TAG=$(date -u +%Y%m%d%H%M%S)
az acr build -t spring-petclinic-vets-service:3.0.1-${IMAGE_TAG} -r crlzaacauhge5deveus spring-petclinic-vets-service/target/docker --build-arg ARTIFACT_NAME=vets-service-3.0.1 --build-arg  EXPOSED_PORT=8080
az acr build -t spring-petclinic-visits-service:3.0.1-${IMAGE_TAG} -r crlzaacauhge5deveus spring-petclinic-visits-service/target/docker --build-arg ARTIFACT_NAME=visits-service-3.0.1 --build-arg  EXPOSED_PORT=8080
az acr build -t spring-petclinic-customers-service:3.0.1-${IMAGE_TAG} -r crlzaacauhge5deveus spring-petclinic-customers-service/target/docker --build-arg ARTIFACT_NAME=customers-service-3.0.1 --build-arg  EXPOSED_PORT=8080
az acr build -t spring-petclinic-api-gateway:3.0.1-${IMAGE_TAG} -r crlzaacauhge5deveus spring-petclinic-api-gateway/target/docker --build-arg ARTIFACT_NAME=api-gateway-3.0.1 --build-arg  EXPOSED_PORT=8080
```