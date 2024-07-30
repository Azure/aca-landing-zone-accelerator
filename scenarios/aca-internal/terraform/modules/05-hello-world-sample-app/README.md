# Deploy the Hello World sample container app

Your [application platform](../04-container-apps-environment/README.md) is now ready to accept workloads. You can deploy a sample "hello world"-style application to see the application platform perform its hosting duties.

## Expected results

A container app using the Hello World sample app is deployed to the Container Apps Environment.

### Public content warning

Public container registries are subject to faults such as outages or request throttling. Interruptions like these can be crippling for a system that needs to pull an image right now. To minimize the risks of using public registries, store all applicable container images in a registry that you control, such as the SLA-backed Azure Container Registry that is deployed with this architecture. For simplicity in this walkthrough, the following deployment will be pulling directly from `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

### Resources

- A container app based on the Hello World sample

## Steps

If you want to use remote storage, uncomment the backend block in the `providers.tf` file and provide the information for your Azure Storage Account. 

1. Decide if you want to deploy this sample workload.

   You can stop at this point if you're interested only in the infrastructure components. If you'd like to skip workload deployment please remember to [:broom: clean up](../../README.md#broom-clean-up-resources) your resources when you are done.

1. Navigate to the Terraform module for the "Hello World" container app.
   
   ```bash
   cd ../05-hello-world-sample-app
   ```

1. Open the terraform.tfvars file in that folder and provide the correct values for the placeholders in `<>`

1. Deploy the Hello World container app.

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```

## Next step

:arrow_forward: [Expose the workload through Application Gateway](../06-application-gateway/README.md)
