# Deploy the Azure Container Apps Environment

With your [spoke virtual network](../02-spoke/README.md) in place and the [services that Azure Containers Apps needs](../03-supporting-services/README.md) in this architecture in place, you're ready to deploy the application platform.

## Expected results

The application platform, Azure Containers Apps, and its logging sinks within Azure Monitor will now be deployed. The workload is not deployed as part of step. Non-mission critical workload lifecycles are usually not tied to the lifecycle of the application platform, and as such are deployed isolated from infrastructure deployments, such as this one. Some cross-cutting concerns and platform feature enablement is usually handled however at this stage.

![A picture of the resources of this architecture, now with the application platform.](./media/container-apps-environment.png)

### Resources

- Container Apps Environment Environment
- Log Analytics Workspace
- Application Insights (optional)
- Dapr Telemetry with Application Insights (optional)
- Private DNS Zone for Container Apps Environment

#### Configure Terraform remote state

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./providers.tf`](./providers.tf) file at lines 11-13 as below:

```hcl
backend "azurerm" {
  resource_group_name  = "<REPLACE with $RESOURCE_GROUP_NAME>"
  storage_account_name = "<REPLACE with $STORAGE_ACCOUNT_NAME>"
  container_name       = "tfstate"
  key                  = "acalza/container-apps-environment.tfstate"
}
```

* `resource_group_name`: Name of the Azure Resource Group that the storage account resides in.
* `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
* `container_name`: Name of the Azure Storage Account Blob Container to store remote state.
* `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.

## Steps

1. Navigate to the Terraform module for the ACA resources.
   
   ```bash
   cd ../04-container-apps-environment
   ```
1. Open the terraform.tfvars file in that folder and provide the correct values for the placeholders in `<>`

1. Create the Azure Container Apps application platform resources.

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```

1. Explore your final infrastructure. *Optional.*

   Now would be a good time to familiarize yourself with all core resources that are part of this architecture, as they are all deployed. This includes the networking layer, the application platform, and all supporting resources. It does not include any of the resources that are specific to a workload (such as public Internet ingress through an application gateway). Check out the following resource groups in the [Azure portal](https://portal.azure.com).

   ```bash
   RESOURCENAME_RESOURCEGROUP_HUB=$(az deployment sub show -n acalza01-hub --query properties.outputs.resourceGroupName.value -o tsv)

   echo Hub Resource Group: $RESOURCENAME_RESOURCEGROUP_HUB && \
   echo Spoke Resource Group: $RESOURCENAME_RESOURCEGROUP_SPOKE
   ```

## Next step

:arrow_forward: [Deploy a sample application](../05-hello-world-sample-app/README.md)