# Deploy the Container Apps

## Docker Images

* Build the images
* Import the public images using az acr import

Get Azure Key Vault name and Azure Container Registry name from the landing zone deployments:

```bash
KEY_VAULT_NAME=$(az deployment sub show -n "ESLZ-Infra-ACA" --query properties.outputs.keyvaultName.value -o tsv)
ACR_NAME=$(az deployment sub show -n "ESLZ-Infra-ACA" --query properties.outputs.acrName.value -o tsv)
```

### Build the images

### Import public images in private Azure Container Registry

### Use public images

To use the public images, run the following command:

```bash
az deployment group create -g "ESLZ-Spoke-RG" -f main.bicep -p parameters-main.json \
  --parameters keyVaultName=$KEY_VAULT_NAME \
  --parameters acrName=$ACR_NAME \
  --parameters vehicleRegistrationServiceImage=ghcr.io/azure/vehicle-registration-service:a4fc4d9 \
  --parameters fineCollectionServiceImage=ghcr.io/azure/fine-collection-service:a4fc4d9 \
  --parameters trafficControlServiceImage=ghcr.io/azure/traffic-control-service:a4fc4d9 \
  --parameters simulationImage=ghcr.io/azure/simulation:a4fc4d9
```

The latest images can be found [here](https://github.com/orgs/Azure/packages?repo_name=java-aks-aca-dapr-workshop).

TODO Add disclaimer

## Deploy the Camera Simulation
