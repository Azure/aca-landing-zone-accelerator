# Supporting Services

The following will be created:

* Azure Container Registry
* Azure Key Vault

An for each of the above:

* Private Link Endpoint
* Related DNS settings for the private endpoint
* A managed identity


![Supporting Services](./media/supporting-services.png)

Review `terraform.tfvars` and update the values as required. Once the files are updated, deploy using the Terraform CLI. 

If you want to use remote storage, uncomment the backend block in the `providers.tf` file and provide the information for your Azure Storage Account. 

Once the files are updated, deploy using the Terraform CLI.

```PowerShell
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```

:arrow_forward: [Container Apps Environment](../04-container-apps-environment)
