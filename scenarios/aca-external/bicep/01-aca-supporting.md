# Create resources that support ACA

The following will be created:

* Azure Container Registry
* Azure Key Vault
* A managed identity

Navigate to "/scenarios/aca-external/bicep/01-aca-supporting" folder

```bash
cd ../01-aca-supporting
```

Review "parameters-main.json" and update the values as required. Once the files are updated, deploy using make, az cli or Az PowerShell

# [Makefile](#tab/CLI)

Review "Makefile" and update the values as required. Once the files are updated, deploy using make

```bash
make
```

# [CLI](#tab/CLI)

```azurecli
az deployment sub create -n "01-aca-supporting" -l "WestEurope" -f main.bicep -p parameters-main.json
```

# [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile parameters-main.json -Location "WestEurope" -Name "01-aca-supporting"
```

:arrow_forward: [](./02-aca-env.md)