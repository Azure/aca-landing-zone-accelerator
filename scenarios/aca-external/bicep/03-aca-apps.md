# Create resources that support ACA

The following will be created:

* ACA App with image from ACR 

Navigate to "/scenarios/aca-external/bicep/03-aca-apps" folder

```bash
cd ../01-aca-apps
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
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile parameters-main.json -Location "WestEurope" -Name "01-aca-apps"
```
