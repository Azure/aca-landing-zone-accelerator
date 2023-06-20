# Azure Container Apps - Internal environment secure baseline [Bicep]

This is the Bicep-based deployment guide for [Scenario 1: Azure Container Apps - Internal environment secure baseline](../README.md).

## Quick deployment to Azure
You can deploy the current LZA directly in your azure subscription using Azure Dev CLI. 

### Deploy to Azure via Portal
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Faca-landing-zone-accelerator%2Fmain%2Fscenarios%2Faca-internal%2Fazure-resource-manager%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Faca-landing-zone-accelerator%2Fmain%2Fscenarios%2Faca-internal%2Fazure-resource-manager%2Fmain-portal-ux.json?v=1)

### Using Codespaces via Azure Dev CLI 

- Visit [github.com/Azure/aca-landing-zone-accelerator](https://github.com/Azure/aca-landing-zone-accelerator)
- Click on the `Green Code` button.
- Navigate to the `CodeSpaces` tab and create a new code space.
- Open the terminal by pressing <code>Ctrl + `</code>.
- Navigate to the scenario folder using the command `cd /workspaces/aca-landing-zone-accelerator/scenarios/aca-internal`.
- Login to Azure using the command `azd auth login`.
- Use the command `azd up` to deploy, provide environment name and subscription to deploy to.
- Finally, use the command `azd down` to clean up resources deployed.

## Prerequisites

This is the starting point for the instructions on deploying this reference implementation. There is required access and tooling you'll need in order to accomplish this.

- An Azure subscription
- The following resource providers [registered](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider):
  - `Microsoft.App`
  - `Microsoft.ContainerRegistry`
  - `Microsoft.ContainerService`
  - `Microsoft.KeyVault`
- The user or service principal initiating the deployment process must have the [owner role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner) at the subscription level to have the ability to create resource groups and to delegate access to others (Azure Managed Identities created from the IaC deployment).
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

1. :world_map: Choose your deployment experience.

   This reference implementation comes with *three* implementation deployment options. They all result in the same resources and architecture, they simply differ in their user experience; specifically how much is abstracted from your involvement.

   - Follow the "[**Standalone deployment guide**](#standalone-deployment-guide)" if you'd like to simply configure a set of parameters and execute a single CLI command to deploy.

     *This will be your simplest deployment approach, but also the most opaque. This is optimized for "cut to the end."*

   - Follow the "[**Standalone deployment guide with GitHub Actions**](#standalone-deployment-guide-with-github-actions)" if you'd like to simply configure a set of parameters and have GitHub Actions execute the deployment.

     *This is a variant of the above. A **fork** of this repo is required for this option, and requires you to create a service principal with appropriate permissions in your Azure Subscription to perform the deployment.*

   - Follow the "[**Standalone deployment guide with Azure Pipelines**](#standalone-deployment-guide-with-azure-pipelines)" if you'd like to simply configure a set of parameters and have Azure Pipelines execute the deployment.

     *This is a variant of the first deployment experience. A **fork** of this repo is required for this option, and requires you to create an appropriate [service connection](https://learn.microsoft.com/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) for the pipeline to connect to your Azure subscription.*

   - Follow the "[**Step-by-step deployment guide**](#step-by-step-deployment-guide)" if you'd like to walk through the deployment at a slower, more deliberate pace.

     *This will approach will allow you to see the deployment evolve over time, which might give you an insight into the various roles and people in your organization that you need to engage when bringing your workload in this architecture to Azure. This is optimized for "learning."*

   All of these options allow you to deploy to a single subscription, to experience the full architecture in isolation. Adapting this deployment to your Azure landing zone implementation is not required to complete the deployments.

## Deployment experiences

### Standalone deployment guide

1. Log into Azure from the AZ CLI and select your subscription.

   ```bash
   az login
   ```

1. Review and update deployment parameters.

   The [**main.parameters.jsonc**](./main.parameters.jsonc) parameter file is where you can customize your deployment. The defaults are a suitable starting point, but feel free to adjust any to fit your requirements.

   **Deployment parameters**

   | Name  | Description | Default | Example(s) |
   | :---- | :---------- | :------ | :--------- |
   | `workloadName` |A suffix that will be used to name resources in a pattern similar to `<resourceAbbreviation>-<applicationName>`. Must be less than 11 characters long, alphanumeric with dashes. | **lzaaca** | **app-svc-01** |
   | `environment` | The short name of the environment. Up to eight characters long. | **dev** | **qa**, **uat**, **prod** |
   | `tags` | Resource tags that you wish to add to all resources. | *none* | `"value": {`<br>`"Environment": "qa",`<br>`"CostCenter": CS004"`<br>`}` |
   | `enableTelemetry` | Enables or disabled telemetry collection | **true** | **false** |
   | `hubResourceGroupName` | The name of the hub resource group to create the hub resources in. | *none*. This results in a new resource group being created. | **rg-byo-hub-academo**. This results in `rg-byo-hub-academo` being used. *This must be an empty resource group, do not use an existing resource group used for other purposes.* |
   | `spokeResourceGroupName` | The name of the spoke resource group to create the spoke resources in. | *none*. This results in a new resource group being created. | **rg-byo-spoke-academo**. This results in `rg-byo-spoke-academo` being used. *This must be an empty resource group, do not use an existing resource group used for other purposes.* |
   | `vnetAddressPrefixes` | An array of string. The address prefixes to use for the hub virtual network. | `["10.0.0.0/16"]` | `["10.100.0.0/16"]` |
   | `enableBastion` | Controls if Azure Bastion is deployed. | `true` | false` |
   | `bastionSubnetAddressPrefix` | CIDR to use for the Azure Bastion subnet. Must be a subset of the hub CIDR ranges. | **10.0.2.0/27** | **10.100.2.0/27** |
   | `vmSize` | The size of the virtual machine to create for the jump box. | `Standard_B2ms` | Any one of: [VM sizes](https://learn.microsoft.om/azure/virtual-machines/sizes) |
   | `vmAdminUsername` | The username to use for the jump box. | **azureuser** | `jumpboxadmin` |
   | `vmAdminPassword` | The password to use for the jump box admin user. | **Password123** :stop_sign: You *should* change this. | Any cryptographically strong password of your choosing. |
   | `vmLinuxSshAuthorizedKeys` | The SSH public key to use for the jump box (if VM is Linux) | *unusable/garbage value* | Any SSH keys you wish in the form of **ssh-rsa AAAAB6NzC...P38/oqQv description**|
   | `vmJumpboxOSType` | The type of OS for the deployed jump box. | **linux** | **windows** |
   | `vmJumpBoxSubnetAddressPrefix` | CIDR to use for the jump box subnet. must be a subset of the hub CIDR ranges. | **10.0.3.0/24** | **10.100.3./24** |
   | `spokeVNetAddressPrefixes` | An array of string. The address prefixes to use for the spoke virtual network. | `["10.1.0.0/22"]` | `["10.101.0./22"]` |
   | `spokeInfraSubnetAddressPrefix` | CIDR of the spoke infrastructure subnet. Must be a subset of the spoke CIDR ranges. | **10.1.0.0/23** | **10.101.0.0/23** |
   | `spokePrivateEndpointsSubnetAddressPrefix` | CIDR of the spoke private endpoint subnet. Must be a subset of the spoke CIDR ranges. | **10.1.2.0/24** | **10.101.2.0/24** |
   | `spokeApplicationGatewaySubnetAddressPrefix` | CIDR of the spoke Application Gateway subnet. Must be a subset of the spoke CIDR ranges. | **10.1.3.0/24** | **10.101.3.0/24** |
   | `enableApplicationInsights` | Controls if Application Insights is deployed and configured. | **true** | **false** |
   | `enableDaprInstrumentation` | Enable Dapr's telemetry. enableApplicationInsights` must also be set to **true** for this to work. | **true** | **false** |
   | `deployHelloWorldSample` | Deploy a simple, sample application to the infrastructure. If you prefer to deploy the more comprehensive, Dapr-enabled sample app, this needs to be disabled | **true** | **false**, because you plan on deploying the Dapr-enabled application instead. |
   | `deployRedisCache` | Feature flag, if true Azure Cache for Redis (Premium SKU), together with Private Endpoint and the relavant Private DNS Zone will be deployed | **false** | **true** |

2. Deploy the reference implementation.

   This will deploy all of the infrastructure to your selected subscription. This will take over 10 minutes to execute.

   ``` bash
   LOCATION=northeurope # or any location that suits your needs
   LZA_DEPLOYMENT_NAME=bicepAcaLzaDeployment  # or any other value that suits your needs

   ```bash
   az deployment sub create \
       --template-file main.bicep \
       --location $LOCATION \
       --name $LZA_DEPLOYMENT_NAME \
       --parameters ./main.parameters.jsonc
   ```

3. Deploy the Dapr-based workload. *Optional.*

   If you chose to set `deployHelloWorldSample` to **false**, then proceed to deploy the Dapr-based workload by following the instructions at:

   :arrow_forward: [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md)

#### :broom: Clean up resources

When you are done exploring the resources created by the Standalone deployment guide, use the following command to remove the resources you created.

```bash
$LZA_DEPLOYMENT_NAME=bicepAcaLzaDeployment  # The name of the deployment you used in the previous step

# get the name of the Spoke Resource Group that has been created previously
SPOKE_RESOURCE_GROUP_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.spokeResourceGroupName.value -o tsv)

# get the name of the Hub Resource Group that has been created previously
HUB_RESOURCE_GROUP_NAME=$(az deployment sub show -n "$LZA_DEPLOYMENT_NAME" --query properties.outputs.hubResourceGroupName.value -o tsv)

az group delete -n $SPOKE_RESOURCE_GROUP_NAME
az group delete -n $HUB_RESOURCE_GROUP_NAME
```

### Standalone deployment guide with GitHub Actions

1. Create a new [service principal](https://learn.microsoft.com/azure/developer/github/connect-from-azure#use-the-azure-login-action-with-a-service-principal-secret) with the **owner** role on the subscription.

   *Replace `{subscription-id}` below.*

   ```bash
   az ad sp create-for-rbac --name "myApp" --role owner \
                       --scopes /subscriptions/{subscription-id} \
                       --sdk-auth
   ```

   > Note that this command will output the following warning `Option '--sdk-auth' has been deprecated and will be removed in a future release.`. Nevertheless, this method is still **strongly recommend** as documented by the [Azure\login team](https://github.com/azure/login#configure-a-service-principal-with-a-secret).

1. Copy the output from the prior command.

   ```json
   {
       "clientId": "<GUID>",
       "clientSecret": "<GUID>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>",
       (...)
   }
   ```

1. Navigate to where you forked the GitHub repository and go to **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.

1. Create a new secret called `AZURE_CREDENTIALS` with the JSON information and press **Add Secret**.

1. On the same screen ( **Settings** > **Secrets and variables** > **Actions** ), you need to add two repository variables. Click on the tab titled **Variables**, and then click on **New repository variable**.

1. Add the first variable named `LOCATION` and enter as value, a valid Azure data center location (i.e. northeurope). This will be the region where all of your resources will be deployed.

1. Add the second variable named `ENABLE_TEARDOWN` typed as a boolean. If you wish the environment to be cleaned up after some manual approval, or after 120 minutes, then set this variable to `true`. If you don't want automatic clean up of the deployed resources, set this variable to `false`. You need also to update the `CODEOWNERS` file, with the right GitHub handles.

#### :broom: Clean up resources

If you didn't select automatic clean up of the deployed resources, use the following commands to remove the resources you created.

```bash
az group delete -n <your-spoke-resource-group>
az group delete -n <your-hub-resource-group>
```
### Standalone deployment guide with Azure Pipelines

1. Navigate into your Azure DevOps projects, click on *Project Settings*, and then on the left sidebar, under the *Pipelines* section, click on the [Service Connections](https://learn.microsoft.com/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml), and then click *New service connection* button and create a new *Azure Resource Manager* service connection. 
   
1. Into your Azure DevOps projects, click on Pipelines on the left sidebar, and then click on **Library**, and then click on *+Variable Group*. Name the new Variable Group "ACA-LZA" and then add the following variables:
   - *location*: The location of where you want the Azure resources deployed
   - *azureServiceConnection*: the name of the service connection you created in the previous step

1. Navigate into your Azure DevOps projects and click on Pipelines on the left sidebar.

1. Click *New Pipeline* in the upper right-hand corner of the window or the *create pipeline* button in the middle if this is your first pipeline. Select *GitHub* as the source for your YAML.

1. Select your repository in GitHub. If you don't already have the Azure Pipeline app installed in your GitHub repository, it will prompt you to enable that and redirect you back to this creation screen.

1. Select *Existing Azure Pipelines YAML file*, select the main branch and the file [lza-deployment-bicep.yaml](../../../.ado/lza-deployment_bicep.yaml).

1.  Once you select the file, click *Next* and then click *Run* in the upper right-hand corner of the *Review* tab. If you don't want to run it immediately, you can click the dropdown on the *Run* button and choose to save it.

> **Note**
   When you first run your pipeline, you may need to give the pipeline permission to access the service connection and the variable group. This will only occur the first time you run the pipeline.

#### :broom: Clean up resources

Use the following commands to remove the resources you created.

```bash
az group delete -n <your-spoke-resource-group>
az group delete -n <your-hub-resource-group>
```

### Step-by-step deployment guide

These instructions are spread over a series of dedicated pages for each step along the way. With this method of deployment, you can leverage the step-by-step process considering where possibly different teams (devops, network, operations etc) with different levels of access, are required to coordinate and deploy all of the required resources.

:arrow_forward: This starts with [Deploy the hub networking resources](./modules/01-hub/README.md).
