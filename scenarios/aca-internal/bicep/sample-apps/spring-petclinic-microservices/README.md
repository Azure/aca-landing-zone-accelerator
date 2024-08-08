```
ENVIRONMENT_NAME=$(az deployment group show -n acalza01-appplat -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerAppsEnvironmentName.value -o tsv)

az deployment group create -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE    -f ../sample-apps/spring-petclinic-microservices/modules/containerapp-java-components.bicep -p managedEnvironments_name=${ENVIRONMENT_NAME}

EUREKA_ID=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.eureka_id.value -o tsv)    
CONFIGSERVER_ID=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.configserver_id.value -o tsv)
RESOURCEID_IDENTITY_ACR=$(az deployment group show -n acalza01-dependencies -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerRegistryUserAssignedIdentityId.value -o tsv)

az deployment group create -n acalza01-appplat-app -g $RESOURCENAME_RESOURCEGROUP_SPOKE    -f ../sample-apps/spring-petclinic-microservices/modules/petclinic.bicep  -p managedEnvironments_name=${ENVIRONMENT_NAME} eureka_id=${EUREKA_ID} configserver_id=${CONFIGSERVER_ID} acr_identity_id=${RESOURCEID_IDENTITY_ACR}
```
