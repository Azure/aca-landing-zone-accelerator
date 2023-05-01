# Hello World Sample Container App (Optional)

Create a container app using Hello World sample app. The image is the public image `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

Review `terraform.tfvars` and update the values as required. Once the files are updated, deploy using the Terraform CLI. 

If you want to use remote storage, uncomment the backend block in the `providers.tf` file and provide the information for your Azure Storage Account. 

Once the files are updated, deploy using the Terraform CLI.

```PowerShell
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```

:arrow_forward: [Application Gateway](../06-application-gateway)
