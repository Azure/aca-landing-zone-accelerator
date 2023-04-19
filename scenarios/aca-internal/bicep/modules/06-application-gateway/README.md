# Application Gateway

The following will be created:
* Application Gateway with public IP
* SSL Certificate in Key Vault of the supporting services
* User Assigned Managed Identity for Application Gateway to access the secret in the Key Vault

![Application Gateway](./media/application-gateway.png)

Review `deploy.app-gateway.parameters.jsonc` and update the values as required. Once the files are updated, deploy using az cli or Az PowerShell.

## [CLI](#tab/CLI)

```azurecli
az deployment group create -n <DEPLOYMENT_NAME> -g <SPOKE_RESOURCE_GROUP> -f deploy.app-gateway.bicep -p deploy.app-gateway.parameters.jsonc
```

Where `<DEPLOYMENT_NAME>` is the name of the deployment and `<SPOKE_RESOURCE_GROUP>` is the name of the spoke resource group.

## [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzResourceGroupDeployment -ResourceGroupName "<SPOKE_RESOURCE_GROUP>" -TemplateFile deploy.app-gateway.bicep -TemplateParameterFile deploy.app-gateway.parameters.jsonc -Name <DEPLOYMENT_NAME>
```

Where `<DEPLOYMENT_NAME>` is the name of the deployment and `<SPOKE_RESOURCE_GROUP>` is the name of the spoke resource group.
