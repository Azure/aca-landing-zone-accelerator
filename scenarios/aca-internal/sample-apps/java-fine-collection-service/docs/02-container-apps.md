# Deploy the Container Apps

There are multiple options provided with this guide to deploy the container images in Azure Container Apps.

## Build and deploy container images

### Get Azure Key Vault name and Azure Container Registry name from the landing zone deployments

```bash
LZA_DEPLOYMENT_NAME="<LZA_DEPLOYMENT_NAME>"
CONTAINER_APPS_ENVIRONMENT_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerAppsEnvironmentName.value -o tsv)
SPOKE_VNET_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokeVnetName.value -o tsv)
SPOKE_PRIVATE_ENDPOINTS_SUBNET_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokePrivateEndpointsSubnetName.value -o tsv)
KEY_VAULT_ID=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.keyVaultId.value -o tsv)
CONTAINER_REGISTRY_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerRegistryName.value -o tsv)
CONTAINER_REGISTRY_USER_ASSIGNED_IDENTITY_ID=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerRegistryUserAssignedIdentityId.value -o tsv)
```

### Option 1 - Build and push the container images in your private Azure Container Registry

* The shell script [jumpbox-setup.sh](../jumpbox-setup.sh) can be used to build the container images in the jumpbox and push it into a private ACR.
* A detailed explanation of how the entire solution and each of the microservices can be built, containerized and deployed can be found in this [workshop](https://azure.github.io/java-aks-aca-dapr-workshop/modules/05-assignment-5-aks-aca/02-aca/1-aca-instructions.html#generate-docker-images-for-applications-and-push-them-to-acr)
* TBD - GitHub actions to build and push the container images in ACR

### Option 2 - Import the public container images available for this solution in Azure Container Registry

All the container image are available in a public image repository. If you do not wish to build the container images from code directly, you can import it directly into the ACR instance as shown below. Note - you might need to execute this from a jumpbox or workstation which can reach your private ACR instance.

```bash
az login

az acr login -n < your acr container registry >

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --source ghcr.io/azure/traffic-control-service:f39c844

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --source ghcr.io/azure/fine-collection-service:a4fc4d9

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --source ghcr.io/azure/vehicle-registration-service:a4fc4d9

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --source ghcr.io/azure/simulation:a4fc4d9
```

The latest images can be found [here](https://github.com/orgs/Azure/packages?repo_name=java-aks-aca-dapr-workshop)

### Option 3 - Use the public container images and deploy them directly in Azure Container Apps

To use the public images, run the following command:

```bash
az deployment group create -g "ESLZ-Spoke-RG" -f main.bicep -p parameters-main.json \
  --parameters keyVaultName=$KEY_VAULT_NAME \
  --parameters acrName=$CONTAINER_REGISTRY_NAME \
  --parameters vehicleRegistrationServiceImage=ghcr.io/azure/vehicle-registration-service:a4fc4d9 \
  --parameters fineCollectionServiceImage=ghcr.io/azure/fine-collection-service:a4fc4d9 \
  --parameters trafficControlServiceImage=ghcr.io/azure/traffic-control-service:a4fc4d9 \
  --parameters simulationImage=ghcr.io/azure/simulation:a4fc4d9
```

## Test the application

To test the E2E deployment of the microservices, there's a simulation service that can be run in of the following three ways.

### 1. Run the Camera Simulation service from your development machine

The application [overview](../README.md) explains how the simulation service sends requests to the traffic control service to simulate vehicles going through the entry and exit cameras. If you run or debug the [simulation](https://github.com/Azure/java-aks-aca-dapr-workshop/tree/e2e-flow/Simulation) service locally, you would need to change the environment variable [`TRAFFIC_CONTROL_SERVICE_BASE_URL`](https://github.com/Azure/java-aks-aca-dapr-workshop/blob/e2e-flow/Simulation/src/main/resources/application.yml#L25) to the URL of the service. In this scenario for the LZA the base url would be the Application Gateway. You can get the public IP of the application gateway from the portal or using cli as shown below:

```bash
$FRONT_END_IP=$(az network application-gateway frontend-ip list --gateway-name <replacewithgatewayname> --resource-group <replacewithresourcegroup>)
```

Note - the LZA uses self-signed certificates in the Application Gateway. If debugging locally do ensure that SSL errors are ignored. In Maven you could do it by passing the `-Dmaven.wagon.http.ssl.insecure = true` argument.

### 2. Run the Simulation service as a Container Apps in the same Container App Environment

The simulation app can also be run as a container in the container app environment provisioned by the LZA. If you have used [Option 3](#option-3---use-the-public-container-images-and-deploy-them-directly-in-azure-container-apps) to build and push the container images in your private ACR then the Simulation service would already be available. The following steps show how to build and push the Simulation service container images from your development machine. Make sure to change the [`TRAFFIC_CONTROL_SERVICE_BASE_URL`](https://github.com/Azure/java-aks-aca-dapr-workshop/blob/e2e-flow/Simulation/src/main/resources/application.yml#L25) to point to  the ingress endpoint of the Vehicle registration service before you build and push the container image. You can get the ingress FQDN for the traffic control service to the following:

```bash
az containerapp show \
  --resource-group <RESOURCE_GROUP_NAME> \
  --name vehicle-registration-service \
  --query properties.configuration.ingress.fqdn
```

The logs can be viewed using the following commands to validate the services running and receiving data from the Simulation service.

```bash
az containerapp revision list \
    -n traffic-control-service \
    -g <resource_group> -o table
```

```bash
ContainerAppConsoleLogs_CL
 | where ContainerName_s == "trafficcontrolservice"
```
