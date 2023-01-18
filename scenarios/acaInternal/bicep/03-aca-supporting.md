# Create resources that support AKS

The following will be created:

* Azure Container Registry
* Azure Key Vault
* Private Link Endpoints for ACR and Key Vault
* Related DNS settings for private endpoints
* A managed identity

Navigate to "/bicep/03-ACA-supporting" folder

```bash
cd ../03-ACA-supporting
```

Review "parameters-main.json" and update the values as required. Once the files are updated, deploy using az cli or Az PowerShell

# [CLI](#tab/CLI)

```azurecli
REGION=EastUS
az deployment sub create -n "ESLZ-ACA-Supporting" -l $REGION -f main.bicep -p parameters-main.json
```

# [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzSubscriptionDeployment -TemplateFile .\03-ACA-supporting\main.bicep -TemplateParameterFile .\03-ACA-supporting\parameters-main.json -Location "EastUS" -Name ESLZ-ACA-Supporting
```

:arrow_forward: [Creation of ACA & enabling Addons](./06-aca-env.md)