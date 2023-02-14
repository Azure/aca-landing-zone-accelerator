# Create resources for the ACA

The following will be created:

* ACA Environment 
* Log Analytics Workspace
* ACR Access to the User managed identity
* Updates to KeyVault access policy with User managed identity

Navigate to "/bicep/04-ACA-Env" folder

```bash
cd ../04-ACA-Env
```


## Deploy the ACA Env
Review "**parameters-main.json**" file and update the values as required. 
        

# [CLI](#tab/CLI)

```azurecli
acrName=$(az deployment sub show -n "ESLZ-ACA-Supporting" --query properties.outputs.acrName.value -o tsv)
keyVaultName=$(az deployment sub show -n "ESLZ-ACA-Supporting" --query properties.outputs.keyvaultName.value -o tsv)
```

### Reference: Follow the below steps if you are going with the Azure CNI Networking option

```
REGION=EastUS
az deployment sub create -n "ESLZ-ACA-Env" -l $REGION -f main.bicep -p parameters-main.json -p acrName=$acrName -p keyvaultName=$keyVaultName 
```


# [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzSubscriptionDeployment -TemplateFile main.bicep -TemplateParameterFile parameters-main.json -Location "EastUS" -Name ESLZ-ACA-Env
```

 az deployment group create -g "ESLZ-spoke"   -f containerapp.bicep

:arrow_forward: [Deploy a Basic Workload](./07-workload.md)
