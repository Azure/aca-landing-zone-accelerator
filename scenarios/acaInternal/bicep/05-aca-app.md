# Create resources for the AKS Cluster

The following will be created:

* ACA App with image from ACR 

Navigate to "/bicep/05-ACA-Apps" folder

```bash
cd ../05-ACA-Apps
```


## Deploy the Container App
Review "**parameters-app.json**" file and update the values as required. 
        

# [CLI](#tab/CLI)

```azurecli
az deployment group create -g "ESLZ-spoke" -f container-app.bicep -p parameters-app.json 
```


# [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzResourceGroupDeployment -ResourceGroupName "ESLZ-spoke" -TemplateFile container-app.bicep -TemplateParameterFile parameters-app.json

```
