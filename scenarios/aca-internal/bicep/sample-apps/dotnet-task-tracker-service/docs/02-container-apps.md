# Deploy the Container Apps

Once the landing zone is deployed, the container apps and their dependencies can be deployed. 

## Build the container images

There are 2 options to build the container images:

1. Import pre-built public images to your private Azure Container Registry
2. Use the pre-built public images from Azure Container Registry

For the first options, you need the name of the container registry. You can get this name from the landing zone deployment:

```bash
LZA_DEPLOYMENT_NAME=<LZA_DEPLOYMENT_NAME>
CONTAINER_REGISTRY_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerRegistryName.value -o tsv)
```

Where `LZA_DEPLOYMENT_NAME` is the name of the deployment of the landing zone.

The latest images can be found [here](https://github.com/orgs/Azure/packages?repo_name=aca-dotnet-workshop)

### Option 1 - Import pre-built public images to your private Azure Container Registry

All the container image are available in a public image repository. If you do not wish to build the container images from code directly, you can import it directly into your private container instance as shown below. Note - you might need to execute this from a jump box or workstation which can reach your private container registry instance.

```bash
TAG=<TAG>
BACKEND_PROCESSOR_IMAGE=$CONTAINER_REGISTRY_NAME.azurecr.io/tasksmanager-backend-processor:$TAG
FRONTEND_IMAGE=$CONTAINER_REGISTRY_NAME.azurecr.io/tasksmanager-frontend-webapp:$TAG
TASKS_API_IMAGE=$CONTAINER_REGISTRY_NAME.azurecr.io/tasksmanager-backend-api:$TAG

az login

az acr login -n $CONTAINER_REGISTRY_NAME

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --image tasksmanager-backend-processor:$TAG \
  --source ghcr.io/azure/tasksmanager-backend-processor:latest

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --image tasksmanager-frontend-webapp:$TAG \
  --source ghcr.io/azure/tasksmanager-frontend-webapp:latest

az acr import \
  --name $CONTAINER_REGISTRY_NAME \
  --image tasksmanager-backend-api:$TAG \
  --source ghcr.io/azure/tasksmanager-backend-api:latest
```

Where `TAG` is the tag of the container images. 

You can set the Bicep parameters for the image in the `main.parameters.jsonc` or use the environment variables defined above.

> **NOTE**
>
> To be able to import the images from the public repository, you need to be logged in to the private Container Registry. To do so you'll need to install Docker in the jump box VM or workstation. The script [jumpbox-setup.sh](../../../../../shared/scripts/jumpbox-setup.sh) can be used as an example on how to install Docker.
>

:arrow_down: [Deploy the sample app](#deploy-the-sample-app)

### Option 2 - Use the public container images and deploy them directly in Azure Container Apps

The public images can be set directly in the `main.parameters.jsonc` file:

```json
{
    "containerRegistryName": {
        "value": ""
    },
    "backendProcessorServiceImage": {
      "value": "ghcr.io/azure/tasksmanager-backend-processor:latest"
    },
    "backendApiServiceImage": {
      "value": "ghcr.io/azure/tasksmanager-backend-api:latest"
    },
    "frontendWebAppServiceImage": {
      "value": "ghcr.io/azure/tasksmanager-frontend-webapp:latest"
    }
}  
```

or in the environment variables:

```bash
CONTAINER_REGISTRY_NAME=
BACKEND_PROCESSOR_IMAGE=ghcr.io/azure/tasksmanager-backend-processor:latest
FRONTEND_IMAGE=ghcr.io/azure/tasksmanager-frontend-webapp:latest
TASKS_API_IMAGE=ghcr.io/azure/tasksmanager-backend-api:latest
```

## Deploy the sample app

The sample app can be deployed using the [main.bicep](../main.bicep) template.

To set the parameters for the deployment, you can either use the `main.parameters.jsonc` file or set environment variables.

### Deploy the sample app using environment variables

You can override the parameters in the `main.parameters.jsonc` when creating the deployment using:

```bash
  --parameters <parameter-name>=<parameter-value>
```

Where `<parameter-name>` is the name of the parameter and `<parameter-value>` is the value of the parameter.

You can get the parameters from the landing zone deployment:

```bash
LZA_DEPLOYMENT_NAME=<LZA_DEPLOYMENT_NAME>
SPOKE_RESOURCE_GROUP_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokeResourceGroupName.value -o tsv)
CONTAINER_APPS_ENVIRONMENT_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerAppsEnvironmentName.value -o tsv)
HUB_VNET_ID=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.hubVNetId.value -o tsv)
SPOKE_VNET_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokeVnetName.value -o tsv)
SPOKE_PRIVATE_ENDPOINTS_SUBNET_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokePrivateEndpointsSubnetName.value -o tsv)
KEY_VAULT_ID=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.keyVaultId.value -o tsv)
CONTAINER_REGISTRY_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerRegistryName.value -o tsv)
CONTAINER_REGISTRY_USER_ASSIGNED_IDENTITY_ID=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.containerRegistryUserAssignedIdentityId.value -o tsv)
SPOKE_APPLICATION_GATEWAY_SUBNET_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokeApplicationGatewaySubnetName.value -o tsv)
# Set app insights name to empty if workload name is same as that of used when deploying the landing zone. If not, Set with the name of the app insights created for the workload
APPLICATION_INSIGHTS_NAME=<APPLICATION_INSIGHTS_NAME>
```

Where `<LZA_DEPLOYMENT_NAME>` is the name of the landing zone deployment.

To deploy the sample app using environment variables, run the following command in the `bicep` folder:

```bash
LZA_DEPLOYMENT_SAMPLE_DOTNET=bicepLzaDeploymentSampleDotNet  # or any other value that suits your needs

az deployment group create -g "$SPOKE_RESOURCE_GROUP_NAME" -f main.bicep -p main.parameters.jsonc \
  --name $LZA_DEPLOYMENT_SAMPLE_DOTNET \
  --parameters containerAppsEnvironmentName=$CONTAINER_APPS_ENVIRONMENT_NAME \
  --parameters hubVNetId=$HUB_VNET_ID \
  --parameters spokeVNetName=$SPOKE_VNET_NAME \
  --parameters spokePrivateEndpointsSubnetName=$SPOKE_PRIVATE_ENDPOINTS_SUBNET_NAME \
  --parameters keyVaultId=$KEY_VAULT_ID \
  --parameters containerRegistryName=$CONTAINER_REGISTRY_NAME \
  --parameters backendProcessorServiceImage=$BACKEND_PROCESSOR_IMAGE\
  --parameters frontendWebAppServiceImage=$FRONTEND_IMAGE \
  --parameters backendApiServiceImage=$TASKS_API_IMAGE \
  --parameters spokeApplicationGatewaySubnetName=$SPOKE_APPLICATION_GATEWAY_SUBNET_NAME \
  --parameters applicationInsightsName=$APPLICATION_INSIGHTS_NAME
```

### Test the sample app

Navigate to the spoke resource group and get the public IP address of the application gateway

```bash
APP_GATEWAY_IP=$(az deployment group show -g "$SPOKE_RESOURCE_GROUP_NAME" -n "$LZA_DEPLOYMENT_SAMPLE_DOTNET" --query properties.outputs.applicationGatewayPublicIp.value -o tsv)

curl -k https://$APP_GATEWAY_IP # or open https://$APP_GATEWAY_IP in a browser
```
