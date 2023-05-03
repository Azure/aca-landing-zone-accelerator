# Enterprise Scale for ACA Internal  - Terraform Implementation

A deployment of ACA-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the cluster infrastructure, and finally the workload itself. This reference implementation  can be used with two different ways, as explained next. The primary purpose of this implementation is to illustrate the topology and decisions of a secure baseline Azure Container Apps environment. 

## Prerequisites 
- Clone this repo (you may need to fork it)
- Install [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Install [Terraform tools](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)
- Register the following Azure Resource Providers (if not already registered)
  -  Microsoft.App
       
        ```bash
        # check if provider is already registered
        az provider list --query "[?namespace=='Microsoft.App'].{Provider:namespace, Status:registrationState}" --output table

        # if provider is not registered, register it
        az provider register --namespace 'Microsoft.App'

        ```
  -  Microsoft.ContainerService
        
        ```bash
        # check if provider is already registered
        az provider list --query "[?namespace=='Microsoft.ContainerService'].{Provider:namespace, Status:registrationState}" --output table

        # if provider is not registered, register it
        az provider register --namespace 'Microsoft.ContainerService'

        ```

### Resource Naming Convention
An effective naming convention consists of resource names from important information about each resource. A good name helps you quickly identify the resource's type, associated workload, environment, and the Azure region hosting it. The naming of the resources in this implementation follow [Azure Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming). Your organization might has already a naming strategy in place, which possibly deviates from the current implementation. The naming of the resources, is automated and centralized, so that in most of the cases can be easily modified or even overridden. The naming module consists of two files
-  [variables.tf](../../shared/terraform/modules/naming/variables.tf). In this file you can override: 
   -  the abbreviation of the resources (`resourceTypeAbbreviations`), which currently follows Azure [recommended abreviations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations). 
   -  the list of azure regions and their abbreviation (`regionAbbreviations`) (NOTE: the list may not be complete - check if the region you plan to deploy is included)
-  [local.tf](../../shared/terraform/modules/naming/local.tf). In this file you can change the way the names are generated, by swapping or removing tokens, adding string identifiers etc. 

### Standalone Deployment Guide

You can deploy the complete landing zone in a single subscription, by using the [main.tf](main.tf) template file and the accompanying [terraform.tfvars](terraform.tfvars) parameter file. You need first to check and customize the parameter file (parameters are described below) and then decide whether you intend to deploy the simple [Hello World App](modules/05-hello-world-sample-app/README.md) or the more comprehensive, Dapr-enabled [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md). If you intend to deploy the [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md), we reccomend that you set the variable `deployHelloWorldSample` to `false`. 

### Setting up your environment

#### Configure Terraform

If you haven't already done so, configure Terraform using one of the following options:

* [Configure Terraform in Azure Cloud Shell with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash)
* [Configure Terraform in Azure Cloud Shell with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell)
* [Configure Terraform in Windows with Bash](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash)
* [Configure Terraform in Windows with PowerShell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)

#### Configure Remote Storage Account

Before you use Azure Storage as a backend, you must create a storage account.
Run the following commands or configuration to create an Azure storage account and container:

Using Azure Powershell module

```powershell

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

```shell
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

### Deploy the Container Apps Landing Zone

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
| vmSize | The size of the virtual machine to create. | [VM Sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)  | 
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

After your Hub, Spoke, supporting services and Azure Container Apps Environment are deployed (and if you selected `deployHelloWorldSample = false`) you may proceed to deploy Fine Collection Sample App
:arrow_forward: [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md)

#### Ingress

The module will deploy everything except Application Gateway which needs to be deployed from the jumpbox deployed as a part of the Hub network. To configure the Application Gateway, we need to provide it an SSL certificate for validating the domain name. The module grabs the certificate data, creates a secret in a KeyVault with the information and the Application Gateway retrieves it from the KeyVault when needed. We will store the SSL certificate in the KeyVault which was deployed as part of the supporting services module. It is behind a private endpoint in the spoke network; therefore, we have to create the secret from a resource inside the network. 

1. Login to your jumpbox using the Bastion service in the Azure Portal
2. Install the Terraform CLI
3. Install Git bash
4. Clone the repository
5. Navigate to the [Application Gateway module](../terraform/modules/06-application-gateway/).
6. You will need to reuse your state storage account from before and create a new state file to manage your Application Gateway. Configure the backend in the [providers.tf](../terraform/modules/06-application-gateway/providers.tf) as was done [previously](#configure-terraform-remote-state)
7. Update the following variables in the [terraform.tfvars](../terraform/modules/06-application-gateway/terraform.tfvars):
   1. resourceGroupName
   2. supportResourceGroupName
   3. keyVaultName
   4. appGatewayFQDN
   5. appGatewayPrimaryBackendEndFQDN
   6. appGatewaySubnetId
   7. appGatewayLogAnalyticsId

8. Run the following commands to deploy

#### Bash shell (i.e. inside WSL2 for windows 11, or any linux-based OS)

```bash
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

#### Clean up resources

To remove the resources created by this landing zone, you can use the following command:

```bash
terraform destroy --var-file=terraform.tfvars
```

### Standalone Deployment Guide With GitHub Action
WIP

#### Setup authentication between Azure and GitHub.
WIP

### End-to-End Deployment with Sample Application

With this method of deployment, you can leverage the step-by-step process, where possibly different teams (devops, network, operations etc) with different levels of access, are required to co-ordinate and deploy all of the required resources. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment. Please read carefully the documentation of each step before deploying it.

1. Preqs - Clone this repo, install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), install [Terraform tools](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)
2. [Hub](modules/01-hub/README.md)
3. [Spoke](modules/02-spoke/README.md)
4. [Supporting Services](modules/03-supporting-services/README.md)
5. [ACA Environment](modules/04-container-apps-environment/README.md)
6. [Hello World Sample Container App (Optional)](modules/05-hello-world-sample-app/README.md)
7. [Application Gateway](modules/06-application-gateway/README.md) or [Front Door](modules/06-front-door/README.md)  