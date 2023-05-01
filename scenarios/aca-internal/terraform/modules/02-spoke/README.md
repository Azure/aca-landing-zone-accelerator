# Spoke

The following will be created:

* Resource Group for the spoke
* Spoke Virtual Network and Subnets
* Peering of Hub and Spoke Networks

![Spoke](./media/spoke.png)

Review `terraform.tfvars` and update the values as required.Once the files are updated, deploy using the Terraform CLI. 

If you want to use remote storage, uncomment the backend block in the `providers.tf` file and provide the information for your Azure Storage Account. 

Once the files are updated, deploy using the Terraform CLI.

```PowerShell
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```


:arrow_forward: [Supporting Services](../03-supporting-services)
