# Spoke

The following will be created:

* Resource Group for the spoke
* Spoke Virtual Network and Subnets
* Peering of Hub and Spoke Networks

![Spoke](./media/spoke.png)

Review `main.parameters.jsonc` and update the values as required.Once the files are updated, deploy using az cli or Az PowerShell.

## [CLI](#tab/CLI)

```azurecli
az deployment sub create -n <DEPLOYMENT_NAME> -l <LOCATION> -f main.bicep -p main.parameters.jsonc
```

 Where `<LOCATION>` is the location where you want to deploy the landing zone and `<DEPLOYMENT_NAME>` is the name of the deployment.

## [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile main.parameters.jsonc -Location "<LOCATION>" -Name <DEPLOYMENT_NAME>
```

Where `<LOCATION>` is the location where you want to deploy the landing zone and `<DEPLOYMENT_NAME>` is the name of the deployment.

:arrow_forward: [Supporting Services](../03-supporting-services)
