# Deploy the spoke network 

In the prior step, you deployed the [regional hub](../01-hub/README.md), now you'll lay out the spoke that will contain the Azure Container Apps instance and related resources.

## Networking in this architecture

The regional spoke network in which your application platform is laid into acts as the first line of defense for your workload. This network perimeter forms a security boundary where you will restrict the network line of sight into your resources. It also gives your application platform the ability to use private link to talk to adjacent platform-as-a-service resources such as Key Vault and Azure Container Registry. And finally it acts as a layer to restrict and tunnel egressing traffic. All of this adds up to ensure that workload traffic stays as isolated as possible and free from any possible external influence, including other enterprise workloads.

## Expected results

After executing these steps you'll have the spoke resource group (`rg-lzaaca-spoke-dev-reg`, by default) populated with a virtual network, subnets, and peering to the regional hub. Based on how you [configured the naming and deployment parameters](../../README.md#steps), your result may be slightly different.

![A picture of the networking components in the spoke resource group.](./media/spoke.png)

### Resources

- Spoke resource group
- Spoke virtual network
- Peering to and from the hub
- Jump box virtual machine (optional)
  
#### Configure Terraform remote state

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./providers.tf`](./providers.tf) file at lines 11-13 as below:

```hcl
backend "azurerm" {
  resource_group_name  = "<REPLACE with $RESOURCE_GROUP_NAME>"
  storage_account_name = "<REPLACE with $STORAGE_ACCOUNT_NAME>"
  container_name       = "tfstate"
  key                  = "acalza/spoke.tfstate"
}
```

* `resource_group_name`: Name of the Azure Resource Group that the storage account resides in.
* `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
* `container_name`: Name of the Azure Storage Account Blob Container to store remote state.
* `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.

## Steps

1. Navigate to the Terraform module for the spoke.
   
   ```bash
   cd ../02-spoke
   ```

1. Open the terraform.tfvars file in that folder and provide the correct values for the placeholders in `<>`

1. Create the regional spoke network.

    ```bash
    terraform init
    terraform plan -out tfplan
    terraform apply tfplan 
    ```

1. Explore your networking resources. *Optional.*

   You may wish to take this moment to familiarize yourself with the resources that have been deployed so far to Azure. They have all been networking resources, establishing the network and access boundaries from within which your application platform will be executing. Check out the resource groups in the [Azure portal](https://portal.azure.com) by looking at the resource group name outputs from the Hub and Spoke modules (spokeResourceGroupName & hubResourceGroupName) in the terminal. 

## Azure landing zone platform alignment

The creation of the hub resources, spoke virtual network, and routing configuration are usually the responsibility of the connectivity platform team. While the creation of subnets, NSGs, and the workload resources are delegated to the workload team. The deployment steps so far have been a mix of both roles. Be sure to understand your organization's separation of duties in landing zone deployments, and use your organization's subscription vending solution to . From this point on in the walkthrough, the steps are indeed all responsibilities of the workload team.

## Next step

:arrow_forward: [Deploy long-lifecycle resources](../03-supporting-services/README.md)