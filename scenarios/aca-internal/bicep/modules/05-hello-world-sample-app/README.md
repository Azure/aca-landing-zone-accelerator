# Deploy the Hello World sample container app

Your [application platform](../04-container-apps-environment/README.md) is now ready to accept workloads. You can deploy a sample "hello world"-style application to see the application platform perform its hosting duties.

## Expected results

A container app using the Hello World sample app is deployed to the Container Apps Environment.

### Public content warning

Public container registries are subject to faults such as outages or request throttling. Interruptions like these can be crippling for a system that needs to pull an image right now. To minimize the risks of using public registries, store all applicable container images in a registry that you control, such as the SLA-backed Azure Container Registry that is deployed with this architecture. For simplicity in this walkthrough, the following deployment will be pulling directly from `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`.

### Resources

- A container app based on the Hello World sample

## Steps

1. Decide if you want to deploy this sample workload.

   You can stop at this point if you're interested only in the infrastructure components. If you'd like to skip workload deployment please remember to [:broom: clean up](../../README.md#broom-clean-up-resources) your resources when you are done.

1. Deploy the Hello World container app.

   ```bash
   RESOURCENAME_RESOURCEGROUP_SPOKE=$(az deployment sub show -n acalza01-spokenetwork --query properties.outputs.spokeResourceGroupName.value -o tsv)
   RESOURCEID_IDENTITY_ACR=$(az deployment group show -n acalza01-dependencies -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerRegistryUserAssignedIdentityId.value -o tsv)
   RESOURCEID_ACA=$(az deployment group show -n acalza01-appplat -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.containerAppsEnvironmentId.value -o tsv)
   echo RESOURCENAME_RESOURCEGROUP_SPOKE: $RESOURCENAME_RESOURCEGROUP_SPOKE && \
   echo RESOURCEID_IDENTITY_ACR: $RESOURCEID_IDENTITY_ACR && \
   echo RESOURCEID_ACA: $RESOURCEID_ACA

   # [This takes about one minute to run.] 
   az deployment group create \
      -n acalza01-helloworld \
      -g $RESOURCENAME_RESOURCEGROUP_SPOKE \
      -f 05-hello-world-sample-app/deploy.hello-world.bicep \
      -p 05-hello-world-sample-app/deploy.hello-world.parameters.jsonc \
      -p containerRegistryUserAssignedIdentityId=${RESOURCEID_IDENTITY_ACR} containerAppsEnvironmentId=${RESOURCEID_ACA}
   ```

## Next step

:arrow_forward: [Expose the workload through Application Gateway](../06-application-gateway/README.md)
