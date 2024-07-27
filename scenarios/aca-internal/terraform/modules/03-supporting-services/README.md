# Deploy the long-lifecycle resources

At this point, you have a [spoke virtual network](../02-spoke/README.md) ready to land your workload into. However, workloads have resources that live on different lifecycle cadences. Here you'll be deploying the resources that have a lifecycle longer than any of your application platform components.

## Expected results

Workloads often have resources that exist on different lifecycles. Some are singletons, and not tied to the deployment stamp of the application platform. Others come and go with the application platform and are part of the application's stamp. Yet others might even be tied to the deployment of code within the application platform. In this deployment, you'll be deploying resources that are not expected to be tied to the same lifecycle as the instance of the Azure Container App, and are in fact dependencies for any given instance and could be used by multiple instances if you had multiple stamps.

![A picture of the long-lived resources that are part of this architecture.](./media/supporting-services.png)

### Resources

- Azure Container Registry
- Azure Key Vault
- Private Link for each, including related DNS Private Zone configuration
- User managed identities for the workload

By default, they are deployed to the spoke resource group.

#### Configure Terraform remote state

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./providers.tf`](./providers.tf) file at lines 11-13 as below:

```hcl
backend "azurerm" {
  resource_group_name  = "<REPLACE with $RESOURCE_GROUP_NAME>"
  storage_account_name = "<REPLACE with $STORAGE_ACCOUNT_NAME>"
  container_name       = "tfstate"
  key                  = "acalza/supporting-services.tfstate"
}
```

* `resource_group_name`: Name of the Azure Resource Group that the storage account resides in.
* `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
* `container_name`: Name of the Azure Storage Account Blob Container to store remote state.
* `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.


## Steps 

1. Navigate to the Terraform module for the supporting services resources.
   
   ```bash
   cd ../03-supporting-services
   ```

1. Open the terraform.tfvars file in that folder and provide the correct values for the placeholders in `<>`

1. Create the regional resources that the Azure Container Apps platform and its applications will be dependent on.

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```

## Private DNS Zones

Private DNS zones in this reference implementation are implemented directly at the spoke level, meaning the workload team creates the private link DNS zones & records for the resources needed; furthermore, the workload is directly using Azure DNS for resolution. Your networking topology might support this decentralized model or instead DNS & DNS zones for Private Link might be handed at the regional hub or in a [VWAN virtual hub extension](https://learn.microsoft.com/azure/architecture/guide/networking/private-link-vwan-dns-virtual-hub-extension-pattern) by your networking team.

If your organization operate a centralized DNS model, you'll need to adapt how DNS zones records are managed this implementation into your existing enterprise networking DNS zone strategy. Since this reference implementation is expected to be deployed isolated from existing infrastructure; this is not something you need to address now; but will be something to understand and address when taking your solution to production.

## Next step

:arrow_forward: [Deploy Azure Container Apps environment](../04-container-apps-environment/README.md)
