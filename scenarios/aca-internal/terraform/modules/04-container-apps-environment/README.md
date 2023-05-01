# Container Apps Environment

The following will be created:

* Container Apps Environment Environment 
* Log Analytics Workspace
* Application Insights (Optional)
* Dapr Telemetry with Application Insights (Optional)
* Private DNS Zone for Container Apps Environment

![Container Apps Environment](./media/container-apps-environment.png)

Review `terraform.tfvars` and update the values as required. Once the files are updated, deploy using the Terraform CLI. 

If you want to use remote storage, uncomment the backend block in the `providers.tf` file and provide the information for your Azure Storage Account. 

Once the files are updated, deploy using the Terraform CLI.

```PowerShell
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```

:arrow_forward: [Hello World Sample Container App (Optional)](../05-hello-world-sample-app)
