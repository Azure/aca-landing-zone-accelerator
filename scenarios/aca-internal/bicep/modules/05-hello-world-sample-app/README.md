# Hello World Sample Container App (Optional)

Create a container app using Hello World sample app. The image is the public image `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

Review `parameters-main.json` and update the values as required. Once the files are updated, deploy using az cli or Az PowerShell.

## [CLI](#tab/CLI)

```azurecli
az deployment group create -n <DEPLOYMENT_NAME> -l <LOCATION> -g <SPOKE_RESOURCE_GROUP> -f main.bicep -p main.parameters.jsonc
```

Where `<LOCATION>` is the location where you want to deploy the landing zone, `<DEPLOYMENT_NAME>` is the name of the deployment and `<SPOKE_RESOURCE_GROUP>` is the name of the spoke resource group.

## [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzResourceGroupDeployment -ResourceGroupName "<SPOKE_RESOURCE_GROUP>" -TemplateFile main.bicep -TemplateParameterFile main.parameters.jsonc -Location "<LOCATION>" -Name <DEPLOYMENT_NAME>
```

Where `<LOCATION>` is the location where you want to deploy the landing zone, `<DEPLOYMENT_NAME>` is the name of the deployment and `<SPOKE_RESOURCE_GROUP>` is the name of the spoke resource group.

:arrow_forward: [Application Gateway](../06-application-gateway)
