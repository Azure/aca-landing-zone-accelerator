# Azure Container Apps - Internal environment secure baseline [Terraform]

This is the Terraform-based deployment guide for [Scenario 1: Azure Container Apps - Internal environment secure baseline]().

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
- Latest [Terraform tools](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)

## Steps 

1. Clone/download this repo locally, or even better fork this repository.

   > :twisted_rightwards_arrows: If you have forked this reference implementation repo, you can configure the provided GitHub workflow. Ensure references to this git repository mentioned throughout the walk-through are updated to use your own fork.

   ```bash
   git clone https://github.com/Azure/aca-landing-zone-accelerator.git
   cd aca-landing-zone-accelerator/scenarios/aca-internal/terraform
   ```
1. Update naming convention. *Optional.*

   The naming of the resources in this implementation follows the Cloud Adoption Framework's resource [naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming). Your organization might have a naming strategy in place, which possibly deviates from this implementation. In most cases you can modified what is deployed by modifying the following two files:

   - [**variables.tf**](../../shared/terraform/modules/naming/variables.tf) contains the nameing convention.
   - [**local.tf**](../../shared/terraform/modules/naming/local.tf) contains the [abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) for resources (`resourceTypeAbbreviations`) and Azure regions (`regionAbbreviations`) used in the naming convention.
2. :world_map: Choose your deployment experience.

   This reference implementation comes with *three* implementation deployment options. They all result in the same resources and architecture, they simply differ in their user experience; specifically how much is abstracted from your involvement.

   - Follow the "[**Standalone deployment guide**](#standalone-deployment-guide)" if you'd like to simply configure a set of parameters and execute a single CLI command to deploy.

     *This will be your simplest deployment approach, but also the most opaque. This is optimized for "cut to the end."*

   - Follow the "[**Step-by-step deployment guide**](#step-by-step-deployment-guide)" if you'd like to walk through the deployment at a slower, more deliberate pace.

     *This will approach will allow you to see the deployment evolve over time, which might give you an insight into the various roles and people in your organization that you need to engage when bringing your workload in this architecture to Azure. This is optimized for "learning."*

   All of these options allow you to deploy to a single subscription, to experience the full architecture in isolation. Adapting this deployment to your Azure landing zone implementation is not required to complete the deployments.

## Deployment experiences

### Standalone Deployment Guide

You can deploy the complete landing zone in a single subscription, by using the [main.tf](main.tf) template file and the accompanying [terraform.tfvars](terraform.tfvars) parameter file. You need first to check and customize the parameter file (parameters are described below) and then decide whether you intend to deploy the simple [Hello World App](modules/05-hello-world-sample-app/README.md) or the more comprehensive, Dapr-enabled [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md). If you intend to deploy the [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md), we reccomend that you set the variable `deployHelloWorldSample` to `false`. 

### Setting up your environment

#### Configure Terraform

If you haven't already done so, configure Terraform using one of the following options:

* [Configure Terraform in Azure Cloud Shell with Bash](https://learn.microsoft.com/azure/developer/terraform/get-started-cloud-shell-bash)
* [Configure Terraform in Azure Cloud Shell with PowerShell](https://learn.microsoft.com/azure/developer/terraform/get-started-cloud-shell-powershell)
* [Configure Terraform in Windows with Bash](https://learn.microsoft.com/azure/developer/terraform/get-started-windows-bash)
* [Configure Terraform in Windows with PowerShell](https://learn.microsoft.com/azure/developer/terraform/get-started-windows-powershell)

#### Configure Remote Storage Account

Before you use Azure Storage as a backend, you must create a storage account.
Run the following commands or configuration to create an Azure storage account and container:

Using Azure Powershell module

```Powershell

$LOCATION="eastus"
$RESOURCE_GROUP_NAME="tfstate"
$STORAGE_ACCOUNT_NAME="tfstate$(Get-Random)"
$CONTAINER_NAME="tfstate"

# Create resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location $LOCATION

# Create storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME -SkuName Standard_LRS -Location $LOCATION -AllowBlobPublicAccess $true

# Create blob container
New-AzStorageContainer -Name $CONTAINER_NAME -Context $storageAccount.context -Permission blob

```

Using Azure CLI

```bash
LOCATION="eastus"
RESOURCE_GROUP_NAME="tfstate"
STORAGE_ACCOUNT_NAME="<tfstate unique name>"
CONTAINER_NAME="tfstate"

# Create Resource Group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create Storage Account
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME -l $LOCATION --sku Standard_LRS

# Create blob container
az storage container-rm create --storage-account $STORAGE_ACCOUNT_NAME --name $CONTAINER_NAME
```

### Deploy the reference implementation

#### Configure Terraform Remote State

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./providers.tf`](./providers.tf) file at lines 11-13 as below:

```hcl
  backend "azurerm" {
    resource_group_name  = "<REPLACE with $RESOURCE_GROUP_NAME>"
    storage_account_name = "<REPLACE with $STORAGE_ACCOUNT_NAME>"
    container_name       = "tfstate"
    key                  = "myapp/terraform.tfstate"
  }
```

* `resource_group_name`: Name of the Azure Resource Group that the storage account resides in.
* `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
* `container_name`: Name of the Azure Storage Account Blob Container to store remote state.
* `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.

#### Provide Parameters Required for Deployment

As you configured the backend remote state with your live Azure infrastructure resource values, you must also provide them for your deployment.

1. Review the available variables with their descriptions and default values in the [variables.tf](./variables.tf) file.
2. Provide any custom values to the defined variables by creating a `terraform.tfvars` file in this [directory](terraform.tfvars)
    * [TF Docs: Variable Definitions (.tfvars) Files](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)

The table below summurizes the avaialble parameters and the possible values that can be set. 

| Name | Description | Example | 
|------|-------------|---------|
|workloadName|A suffix that will be used to name the resources in a pattern similar to ` <resourceAbbreviation>-<applicationName> ` . Must be up to 10 characters long, alphanumeric with dashes|app-svc-01|
|environment|Required. The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.||
|tags|Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)|"tags": {<br>         "value": { <br>               "deployment": "terraform", <br>  "key1": "value1" <br>           } <br>         } |
| enableTelemetry | boolean, Telemetry collection is on by default `true` | | 
| hubResourceGroupName | Optional default value `""`, The name of the hub resource group to create the resources in. If set, it overrides the name generated by the template | | 
| spokeResourceGroupName | Optional default value `""`, The name of the spoke resource group to create the resources in. If set, it overrides the name generated by the template | | 
| vnetAddressPrefixes | An array of string. The address prefixes to use for the hub virtual network. | | 
| bastionSubnetAddressPrefix | CIDR to use for the Azure Bastion subnet |  | 
| vmSize | The size of the virtual machine to create. | [VM Sizes](https://learn.microsoft.com/azure/virtual-machines/sizes)  | 
| vmAdminUsername | The username to use for the virtual machine |  | 
| vmAdminPassword | The password to use for the virtual machine |  | 
| vmLinuxSshAuthorizedKeys | The SSH public key to use for the virtual machine (if VM is linux) |  | 
| vmJumpboxOSType | The type of OS for the deployed jump box - Can be `Linux` or `Windows` |  | 
| vmJumpBoxSubnetAddressPrefix | CIDR to use for the virtual machine subnet |  | 
| spokeVNetAddressPrefixes | An array of string. The address prefixes to use for the spoke virtual network |  | 
| spokeInfraSubnetAddressPrefix | CIDR of the Spoke Infrastructure Subnet |  | 
| spokePrivateEndpointsSubnetAddressPrefix | CIDR of the Spoke Private Endpoints Subnet |  | 
| spokeApplicationGatewaySubnetAddressPrefix | CIDR of the Spoke Application Gateway Subnet |  | 
| enableApplicationInsights | If you want to deploy Application Insights, set this to `true` |  |
| enableDaprInstrumentation | If you use Dapr, you can setup Dapr telemetry by setting this to true and enableApplicationInsights to `true` |  |
| deployHelloWorldSample | Set this to `true` if you want to deploy the sample application and the application gateway |NOTE: if you prefer to deploy the more comprehensive, Dapr-enabled [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md) set this parameter to `false` |

#### Deploy

#### Bash shell (i.e. inside WSL2 for windows 11, or any linux-based OS)
``` bash
terraform init
terraform plan --var-file terraform.tfvars -out tfplan
terraform apply tfplan
```
#### Powershell (windows based OS)
``` powershell
terraform init
terraform plan --var-file terraform.tfvars -out tfplan
terraform apply tfplan
```

1. Deploy the Dapr-based workload. *Optional.*

   If you chose to set `deployHelloWorldSample` to **false**, then proceed to deploy the Dapr-based workload by following the instructions at:

   :arrow_forward: [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md)


#### :broom: Clean up resources

When you are done exploring the resources created by the Standalone deployment guide, use the following command to remove the resources you created.

```bash
terraform destroy --var-file=terraform.tfvars
```

### Step-by-step deployment guide

These instructions are spread over a series of dedicated pages for each step along the way. With this method of deployment, you can leverage the step-by-step process considering where possibly different teams (devops, network, operations etc) with different levels of access, are required to coordinate and deploy all of the required resources.

:arrow_forward: This starts with [Deploy the hub networking resources](./modules/01-hub/README.md).