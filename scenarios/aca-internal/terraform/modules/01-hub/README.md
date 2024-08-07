# Deploy the regional hub

This is the first step in the step-by-step deployment guide for the [Azure Container Apps - Internal environment secure baseline](../../README.md). This hub will be the egress point for all traffic in connected spokes.

## Networking in this architecture

Egressing your spoke traffic through a hub network (following the hub-spoke model), is a critical component of this architecture. Your organization's networking team will likely have a specific strategy already in place for this; such as a Connectivity subscription already configured for regional egress. In this walkthrough, we are going to implement this recommended strategy in an illustrative manner, however you will need to adjust based on your specific situation when you implement this cluster for production. Hubs are usually a centrally-managed and governed resource in an organization, and not typically workload specific. The steps that follow create the hub (and spokes) as a stand-in for the work that you'd coordinate with your networking team.

## Expected results

After executing these steps you'll have the hub resource group (`rg-lzaaca-hub-dev-reg`, by default) populated with a regional virtual network, Azure Bastion, and Azure Firewall. Based on how you [configured the naming and deployment parameters](../../README.md#steps), your result may be slightly different. No spokes will have been created yet.

![A picture of the components in the hub resource group.](./media/hub.png)

### Resources

- Hub resource group
- Hub virtual network
- Azure Bastion (optional)
- Azure Firewall (optional)

### IP addressing

Since this walkthrough is expected to be deployed isolated from existing infrastructure and not joined to any of your existing networks; the IP addresses should not come in conflict with any existing networking you have, even if those IP addresses overlap with ones you already have in your enterprise. However, if you need to join existing networks, even for the purposes this walkthrough, you'll need to adjust the IP space before deploying. See [Review and update deployment parameters](../../README.md#steps).

#### Configure Terraform remote state

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./providers.tf`](./providers.tf) file at lines 11-13 as below:

```hcl
backend "azurerm" {
  resource_group_name  = "<REPLACE with $RESOURCE_GROUP_NAME>"
  storage_account_name = "<REPLACE with $STORAGE_ACCOUNT_NAME>"
  container_name       = "tfstate"
  key                  = "acalza/hub.tfstate"
}
```

* `resource_group_name`: Name of the Azure Resource Group that the storage account resides in.
* `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
* `container_name`: Name of the Azure Storage Account Blob Container to store remote state.
* `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.

## Steps

1. Navigate to the Terraform module for the hub. 
   
   ```bash
   cd modules/01-hub
   ```

2. Set the desired region and Virtual Machine Administrator Password in the [terraform.tfvars file](./terraform.tfvars)
   :stop_sign: Update this to your desired region.

   ```Terraform
   location="eastus" # or any location that suits your needs
   vmAdminPassword = "<Strong Password>"
   ```

3. Create the regional network hub

    ```bash
    terraform init
    terraform plan -out tfplan
    terraform apply tfplan 
    ```

## Next step
:arrow_forward: [Spoke](../02-spoke/README.md)
