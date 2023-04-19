# Hello World Sample Container App (Optional)

Create a container app using Hello World sample app. The image is the public image `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

Review `deploy.hello-world.parameters.jsonc` and update the values as required. Once the files are updated, deploy using az cli or Az PowerShell.

## [CLI](#tab/CLI)

```azurecli
az deployment group create -n <DEPLOYMENT_NAME> -g <SPOKE_RESOURCE_GROUP> -f deploy.hello-world.bicep -p deploy.hello-world.parameters.jsonc
```

Where <DEPLOYMENT_NAME>` is the name of the deployment and `<SPOKE_RESOURCE_GROUP>` is the name of the spoke resource group.

## [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzResourceGroupDeployment -ResourceGroupName "<SPOKE_RESOURCE_GROUP>" -TemplateFile deploy.hello-world.bicep -TemplateParameterFile deploy.hello-world.parameters.jsonc -Name <DEPLOYMENT_NAME>
```

Where `<DEPLOYMENT_NAME>` is the name of the deployment and `<SPOKE_RESOURCE_GROUP>` is the name of the spoke resource group.

:arrow_forward: [Application Gateway](../06-application-gateway)
