# Supporting Services

The following will be created:

* Azure Container Registry
* Azure Key Vault

An for each of the above:

* Private Link Endpoint
* Related DNS settings for the private endpoint
* A managed identity


![Supporting Services](./media/supporting-services.png)

Review `deploy.supporting-services.parameters.jsonc` and update the values as required. Once the files are updated, deploy using az cli or Az PowerShell.

## [CLI](#tab/CLI)

```azurecli
az deployment group create -n <DEPLOYMENT_NAME> -g <SUPPORTING_SERVICES_RESOURCE_GROUP> -f deploy.supporting-services.bicep -p deploy.supporting-services.parameters.jsonc
```

Where `<DEPLOYMENT_NAME>` is the name of the deployment and `<SUPPORTING_SERVICES_RESOURCE_GROUP>` is the name of the resource group where the supporting services will be deployed.

## [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzResourceGroupDeployment -ResourceGroupName "<SUPPORTING_SERVICES_RESOURCE_GROUP>" -TemplateFile deploy.supporting-services.bicep -TemplateParameterFile deploy.supporting-services.parameters.jsonc -Name <DEPLOYMENT_NAME>
```

Where `<DEPLOYMENT_NAME>` is the name of the deployment and `<SUPPORTING_SERVICES_RESOURCE_GROUP>` is the name of the resource group where the supporting services will be deployed.

:arrow_forward: [Container Apps Environment](../04-container-apps-environment)
