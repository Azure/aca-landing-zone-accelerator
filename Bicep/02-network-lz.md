# Create the Landing Zone Network

The following will be created:

* Resource Group for Landing Zone Networking
* Spoke Virtual Network and Subnets
* Peering of Hub and Spoke Networks
* Private DNS Zones(Please Review)

Navigate to "/02-Network-LZ" folder

```bash
cd ../02-Network-LZ
```

Review "parameters-main.json" and update the values as required.Once the files are updated, deploy using az cli or Az PowerShell

# [CLI](#tab/CLI)

```azurecli
REGION=EastUS
az deployment sub create -n "ESLZ-Spoke-ACA" -l $REGION -f main.bicep -p parameters-main.json


az deployment sub create -n "ESLZ-ACA-SPOKE-NSG" -l $REGION -f updateNSG.bicep -p parameters-updateNSG.json
```

# [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzSubscriptionDeployment -TemplateFile .\04-Network-LZ\main.bicep -TemplateParameterFile .\04-Network-LZ\parameters-main.json -Location "EastUS" -Name ESLZ-Spoke-AKS



New-AzSubscriptionDeployment -TemplateFile .\04-Network-LZ\updateNSG.bicep -TemplateParameterFile .\04-Network-LZ\parameters-updateNSG.json -Location "EastUS" -Name ESLZ-AKS-SPOKE-NSG
```

:arrow_forward: [Creation of Supporting Components for ACA](./03-aca-supporting.md)