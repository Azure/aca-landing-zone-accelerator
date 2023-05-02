# Azure Container Apps - Internal environment secure baseline [Bicep]

This is the Bicep-based deployment guide for [Scenario 1: Azure Container Apps - Internal environment secure baseline](../README.md).

## Prerequisites

This is the starting point for the instructions on deploying this rference implementation. There is required access and tooling you'll need in order to accomplish this.

- An Azure subscription
- The following resource providers [registered](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider):
  - `Microsoft.App`
  - `Microsoft.ContainerRegistry`
  - `Microsoft.ContainerService`
  - `Microsoft.KeyVault`
- The user or service principal initiating the deployment process must have the [Contributor role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) at the subscription level to have the ability to create resource groups.
- Latest [Azure CLI installed](https://learn.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest) (must be at least 2.40), or you can perform this from Azure Cloud Shell by clicking below.

  [![Launch Azure Cloud Shell](https://learn.microsoft.com/azure/includes/media/cloud-shell-try-it/launchcloudshell.png)](https://shell.azure.com)

## Steps

1. Clone/download this repo locally, or even better fork this repository.

   > :twisted_rightwards_arrows: If you have forked this reference implementation repo, you can configure the provided GitHub workflow. Ensure references to this git repository mentioned throughout the walk-through are updated to use your own fork.

   ```bash
   git clone https://github.com/Azure/aca-landing-zone-accelerator.git
   cd aca-landing-zone-accelerator/scenarios/aca-internal/bicep
   ```

1. Update naming convention. *Optional.*

   The naming of the resources in this implementation follows the Cloud Adoption Framework's resource [naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming). Your organization might have a naming strategy in place, which possibly deviates from this implementation. In most cases you can modified what is deployed by modifying the following two files:

   - [**naming.module.bicep**](../../shared/bicep/naming/naming.module.bicep) contains the nameing convention.
   - [**naming-rules.jsonc**](../../shared/bicep/naming/naming-rules.jsonc) contains the [abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) for resources (`resourceTypeAbbreviations`) and Azure regions (`regionAbbreviations`) used in the naming convention.

1. Choose your deployment experience.

   This reference implementation comes with *three* implementation deployment options. They all result in the same resources and architecture, they simply differ in their user experience; specifically how much is abstracted from your involvement.

   - Follow the "[**Standalone deployment guide**](#standalone-deployment-guide)" if you'd like to simply configure a set of parameters and execute a single CLI command to deploy.

     *This will be your simplest deployment approach, but also the most opaque. This is optimized for "cut to the end."*

   - Follow the "[**Standalone deployment guide with GitHub Actions**](#standalone-deployment-guide-with-github-actions)" if you'd like to simply configure a set of parameters and have GitHub Actions execute the deployment.

     *This is a varient of the above. A **fork** of this repo is required for this option, and requires you to create a service principal with appropriate permissions in your Azure Subscription to perform the deployment.*

   - Follow the "["**Step-by-step deployment guide**"](#end-to-end-deployment-with-sample-application) if you'd like to walk through the deployment at a slower, more deliberate pace.

     *This will approach will allow you to see the deployment evolve over time, which might give you an insight into the various roles and people in your organization that you need to engage when bringing your workload in this architecture to Azure. This is optimized for "learning."*

   All of these options allow you to deploy to a single subscription, to experience the full architecture in isolation. Adapting this deployment to your Azure landing zone implementation is not required to complete the deployments.

## Deployment experiences

### Standalone deployment guide

TODO STOPPED HERE

YYou can deploy the complete landing zone in a single subscription, by using the [main.bicep](main.bicep) template file and the accompanying [main.parameters.jsonc](main.parameters.jsonc) parameter file. You need first to check and customize the parameter file (parameters are described below) and then decide whether you intend to deploy the simple [Hello World App](modules/05-hello-world-sample-app/README.md) or the more comprehensive, Dapr-enabled [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md). If you intend to deploy the [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md), we reccomend that you set the parameter `deployHelloWorldSample` to `false`.

#### Deployment parameters

The table below summurizes the avaialble parameters and the possible values that can be set. 

| Name | Description | Example | 
|------|-------------|---------|
|workloadName|A suffix that will be used to name the resources in a pattern similar to ` <resourceAbbreviation>-<applicationName> ` . Must be up to 10 characters long, alphanumeric with dashes|app-svc-01|
|environment|Required. The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.||
|tags|Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)|"tags": {<br>         "value": { <br>               "deployment": "bicep", <br>  "key1": "value1" <br>           } <br>         } |
| enableTelemetry | boolean, Telemetry collection is on by default `true` | | 
| hubResourceGroupName | Optional default value `""`, The name of the hub resource group to create the resources in. If set, it overrides the name generated by the template | | 
| spokeResourceGroupName | Optional default value `""`, The name of the spoke resource group to create the resources in. If set, it overrides the name generated by the template | | 
| vnetAddressPrefixes | An array of string. The address prefixes to use for the hub virtual network. | | 
| bastionSubnetAddressPrefix | CIDR to use for the Azure Bastion subnet |  | 
| vmSize | The size of the virtual machine to create. | [VM Sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)  | 
| vmAdminUsername | The username to use for the virtual machine |  | 
| vmAdminPassword | The password to use for the virtual machine |  | 
| vmLinuxSshAuthorizedKeys | The SSH public key to use for the virtual machine (if VM is linux) |  | 
| vmJumpboxOSType | The type of OS for the deployed jump box - Can be `linux` or `windows` |  | 
| vmJumpBoxSubnetAddressPrefix | CIDR to use for the virtual machine subnet |  | 
| spokeVNetAddressPrefixes | An array of string. The address prefixes to use for the spoke virtual network |  | 
| spokeInfraSubnetAddressPrefix | CIDR of the Spoke Infrastructure Subnet |  | 
| spokePrivateEndpointsSubnetAddressPrefix | CIDR of the Spoke Private Endpoints Subnet |  | 
| spokeApplicationGatewaySubnetAddressPrefix | CIDR of the Spoke Application Gateway Subnet |  | 
| enableApplicationInsights | If you want to deploy Application Insights, set this to `true` |  |
| enableDaprInstrumentation | If you use Dapr, you can setup Dapr telemetry by setting this to true and enableApplicationInsights to `true` |  |
| deployHelloWorldSample | Set this to `true` if you want to deploy the sample application and the application gateway |NOTE: if you prefer to deploy the more comprehensive, Dapr-enabled [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md) set this parameter to `false` |


After the parameters have been initialized, you can deploy the Landing Zone Accelerator resources with the following `az cli` command:


#### Bash shell (i.e. inside WSL2 for windows 11, or any linux-based OS)
``` bash
LOCATION=northeurope # or any location that suits your needs
LZA_DEPLOYMENT_NAME=bicepAcaLzaDeployment  # or any other value that suits your needs

az deployment sub create \
    --template-file main.bicep \
    --location $LOCATION \
    --name $LZA_DEPLOYMENT_NAME \
    --parameters ./main.parameters.jsonc
```

#### Powershell (windows based OS)
``` powershell
$LOCATION=northeurope # or any location that suits your needs
$LZA_DEPLOYMENT_NAME=bicepAcaLzaDeployment  # or any other value that suits your needs

az deployment sub create `
    --template-file main.bicep `
    --location $LOCATION `
    --name $LZA_DEPLOYMENT_NAME `
    --parameters ./main.parameters.jsonc
```
After your Hub, Spoke, supporting services and Azure Container Apps Environment are deployed (and if you selected `deployHelloWorldSample: false`) you may proceed to deploy Fine Collection Sample App
:arrow_forward: [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md)

#### Clean up resources

To remove the resources created by this landing zone, you can use the following command:

```bash
$LZA_DEPLOYMENT_NAME=bicepAcaLzaDeployment  # The name of the deployment you used in the previous step

# get the name of the Spoke Resource Group that has been created previously
SPOKE_RESOURCE_GROUP_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokeResourceGroupName.value -o tsv)

# get the name of the Hub Resource Group that has been created previously
HUB_RESOURCE_GROUP_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.hubResourceGroupName.value -o tsv)

az group delete -n $SPOKE_RESOURCE_GROUP_NAME --yes
az group delete -n $HUB_RESOURCE_GROUP_NAME --yes
```

### Standalone Deployment Guide With GitHub Actions
With this method, you can leverage the included [LZA Deployment GitHub action](../../../.github/workflows/lza-deployment.yml) to deploy the Azure Container Apps Infrastructure resources. 
> NOTE: To use the GitHub action you need to [fork the repository](https://github.com/Azure/ACA-Landing-Zone-Accelerator/fork) to your organization. 

#### Setup authentication between Azure and GitHub.
The easiest way to do that, is to use a [service principal](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret). 
 1. Open [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) in the Azure Portal or [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) locally
2. Create a new service principal in the Azure portal for your app and assign it **Contributor** role. Replace {subscription-id}. The service principal will be created at the scope of the subscription as multiple resource groups will be created.
   ```
   az ad sp create-for-rbac --name "myApp" --role owner \
                       --scopes /subscriptions/{subscription-id} \
                       --sdk-auth
   ```
   > Note that this command will output the following warning `Option '--sdk-auth' has been deprecated and will be removed in a future release.`. Nevertheless, this method is still **strongly recommend** as documented by the [Azure\login team](https://github.com/azure/login#configure-a-service-principal-with-a-secret).
3. Copy the JSON object for your service principal
   ```json
   {
       "clientId": "<GUID>",
       "clientSecret": "<GUID>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>",
       (...)
   }
   ```
4. Navigate to where you cloned the GitHub repository and go to **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.
5. Create a new secret called `AZURE_CREDENTIALS` with the JSON information in step 3 (in JSON format) and press *Add Secret*.
6. On the same screen ( **Settings** > **Secrets and variables** > **Actions** ), we need to add two repository variables. Click on the Tab Page titled **Variables**, and then click on **New repository variable**
   1. Add the first variable named `LOCATION` and enter as value, a valid Azure datacenter location (i.e. northeurope). This will be the region where all of your resources will be deployed.
   2. Add the second variable named `ENABLE_TEARDOWN` typed as a boolean. If you wish the environment to be cleaned up after some manual approval, or after 120 minutes, then set this variable to `true`. If you don't want automatic clean up of the deployed resources, set this variable to `false`. You need also to update the `CODEOWNERS` file, whith the right GitHub handles.  

### End-to-End Deployment with Sample Application

With this method of deployment, you can leverage the step-by-step process, where possibly different teams (devops, network, operations etc) with different levels of access, are required to co-ordinate and deploy all of the required resources. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment. Please read carefully the documentation of each step before deploying it.

1. Preqs - Clone this repo, install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), install [Bicep tools](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
2. [Hub](modules/01-hub/README.md)
3. [Spoke](modules/02-spoke/README.md)
4. [Supporting Services](modules/03-supporting-services/README.md)
5. [ACA Environment](modules/04-container-apps-environment/README.md)
6. [Hello World Sample Container App (Optional)](modules/05-hello-world-sample-app/README.md)
7. [Application Gateway](modules/06-application-gateway/README.md) or [Front Door](modules/06-front-door/README.md)  
