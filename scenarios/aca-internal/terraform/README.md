# Azure Container Apps - Internal environment secure baseline [Terraform]

This is the Terraform-based deployment guide for [Scenario 1: Azure Container Apps - Internal environment secure baseline](../README.md).

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
- PowerShell 7.0, if you would like to use PowerShell to do your Azure Storage Account for Terraform Remote State 

## Steps 

1. Clone/download this repo locally, or even better fork this repository.

   ```bash
   git clone https://github.com/Azure/aca-landing-zone-accelerator.git
   cd aca-landing-zone-accelerator/scenarios/aca-internal/terraform
   ```
2. Update naming convention. *Optional.*

   The naming of the resources in this implementation follows the Cloud Adoption Framework's resource [naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming). Your organization might have a naming strategy in place, which possibly deviates from this implementation. In most cases you can modified what is deployed by modifying the following two files:

   - [**variables.tf**](../../shared/terraform/modules/naming/variables.tf) contains the naming convention.
   - [**local.tf**](../../shared/terraform/modules/naming/local.tf) contains the [abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) for resources (`resourceTypeAbbreviations`) and Azure regions (`regionAbbreviations`) used in the naming convention.

   All of these options allow you to deploy to a single subscription, to experience the full architecture in isolation. Adapting this deployment to your Azure landing zone implementation is not required to complete the deployments.

## Deployment experiences

### Setting up your environment

#### Configure Terraform

If you haven't already done so, configure Terraform using one of the following options:

* [Configure Terraform in Azure Cloud Shell with Bash](https://learn.microsoft.com/azure/developer/terraform/get-started-cloud-shell-bash)
* [Configure Terraform in Azure Cloud Shell with PowerShell](https://learn.microsoft.com/azure/developer/terraform/get-started-cloud-shell-powershell)
* [Configure Terraform in Windows with Bash](https://learn.microsoft.com/azure/developer/terraform/get-started-windows-bash)
* [Configure Terraform in Windows with PowerShell](https://learn.microsoft.com/azure/developer/terraform/get-started-windows-powershell)
* [Run the commands using a local devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) using the config provided in this repo's .devcontainer folder

#### Configure remote state storage account

Before you use Azure Storage as a backend for the state file, you must create a storage account.
Run the following commands or configuration to create an Azure storage account and container:

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

As you configured the backend remote state with your live Azure infrastructure resource values, you must also provide them for your deployment.

The table below summarizes the available parameters and the possible values that can be set. 

   | Name  | Description | Default | Example(s) |
   | :---- | :---------- | :------ | :--------- |
   | `workloadName` |A suffix that will be used to name resources in a pattern similar to `<resourceAbbreviation>-<applicationName>`. Must be less than 11 characters long, alphanumeric with dashes. | **lzaaca** | **app-svc-01** |
   | `environment` | The short name of the environment. Up to eight characters long. | **dev** | **qa**, **uat**, **prod** |
   | `location` | The name of the deployment region. | **northeurope** | **eastus**, **westus2**, **eastus2** |
   | `tags` | Resource tags that you wish to add to all resources. | *none* | `"value": {`<br>`"Environment": "qa",`<br>`"CostCenter": CS004"`<br>`}` |
   | `enableTelemetry` | Enables or disabled telemetry collection | **true** | **false** |
   | `ddosProtectionPlanId` | ID of DDOS Protection Plan for hub vnet | **none** | **abc123** |
   | `containerAppsSecurityRules` | NSG rules for ACA subnet | **See TF Vars file** | **See TF Vars file** |
   | `appGatewaySecurityRules` | NSG rules for Application Gateway | **See TF Vars file** | **See TF Vars file** |
   | `hubResourceGroupName` | The name of the hub resource group to create the hub resources in. | *none*. This results in a new resource group being created. | **rg-byo-hub-academo**. This results in `rg-byo-hub-academo` being used. *This must be an empty resource group, do not use an existing resource group used for other purposes.* |
   | `spokeResourceGroupName` | The name of the spoke resource group to create the spoke resources in. | *none*. This results in a new resource group being created. | **rg-byo-spoke-academo**. This results in `rg-byo-spoke-academo` being used. *This must be an empty resource group, do not use an existing resource group used for other purposes.* |
   | `supportingResourceGroupName` | The name of the supporting resource group to create the supporting resources in. | *none*. This results in a new resource group being created. | **rg-byo-support-academo**. This results in `rg-byo-support-academo` being used. *This must be an empty resource group, do not use an existing resource group used for other purposes.* |
   | `hubVnetAddressPrefixes` | An array of strings. The address prefixes to use for the hub virtual network. | `["10.0.0.0/24"]` | `["10.100.0.0/24"]` |
   | `gatewaySubnetAddressPrefix` | A string. The address prefix to use for the gateway subnet in the virtual network. | `"10.0.0.0/24"` | `"10.100.0.0/24"` |
   | `azureFirewallSubnetAddressPrefix` | A string. The address prefix to use for the Azure Firewall subnet in the virtual network. | `""10.0.0.64/26""` | `""10.0.0.64/26""` |
   | `bastionSubnetAddressPrefixes` | An array of strings. The address prefixes to use for the Azure Bastion subnet in the virtual network. | `["10.0.0.128/26"]` | `["10.0.0.128/26"]` |
   | `azureFirewallSubnetManagementAddressPrefix` | A string. The address prefix to use for the Azure Firewall Management subnet in the virtual network. | `"10.0.0.192/26"` | `"10.0.0.192/26"` |
   | `spokeVNetAddressPrefixes` | An array of string. The address prefixes to use for the spoke virtual network. | `["10.1.0.0/22"]` | `["10.101.0./22"]` |
   | `vmJumpBoxSubnetAddressPrefix` | CIDR of the spoke infrastructure subnet. Must be a subset of the spoke CIDR ranges. | **10.1.2.32/27** | **10.1.2.32/27** |
   | `infraSubnetAddressPrefix` | CIDR of the spoke infrastructure subnet. Must be a subset of the spoke CIDR ranges. | **10.1.0.0/27** | **10.101.0.0/27** |
   | `infraSubnetName` | Name of spoke infrastructure subnet | **snet-infra** | **snet-infra** |
   | `privateEndpointsSubnetAddressPrefix` | CIDR of the spoke private endpoint subnet. Must be a subset of the spoke CIDR ranges. | **10.1.2.0/27** | **10.101.2.0/27** |
   | `privateEndpointsSubnetName` | Name of spoke private endpoint subnet | **snet-pep** | **snet-pep** |
   | `applicationGatewaySubnetAddressPrefix` | CIDR of the spoke Application Gateway subnet. Must be a subset of the spoke CIDR ranges. | **10.1.3.0/24** | **10.101.3.0/24** |
   | `applicationGatewaySubnetName` | Name of spoke Application Gateway subnet | **snet-agw** | **snet-agw** |
   | `gatewaySubnetAddressPrefix` | CIDR of the Gateway subnet. Must be a subset of the spoke CIDR ranges. | **10.1.3.0/24** | **10.101.3.0/24** |
   | `gatewaySubnetName` | Name of Gateway subnet | **GatewaySubnet** | **GatewaySubnet** |
   | `azureFirewallSubnetName` | Name of Azure Firewall subnet | **AzureFirewallSubnet** | **AzureFirewallSubnet** |
   | `enableBastion` | Controls if Azure Bastion is deployed. | `true` | false` |
   | `vmSize` | The size of the virtual machine to create for the jump box. | `Standard_B2ms` | Any one of: [VM sizes](https://learn.microsoft.om/azure/virtual-machines/sizes) |
   | `vmAdminUsername` | The username to use for the jump box. | **vmadmin** | `jumpboxadmin` |
   | `vmAdminPassword` | The password to use for the jump box admin user. | **Password123** :stop_sign: You *should* change this. | Any cryptographically strong password of your choosing. |
   | `vmLinuxSshAuthorizedKeys` | The SSH public key to use for the jump box (if VM is Linux) | *unusable/garbage value* | Any SSH keys you wish in the form of **ssh-rsa AAAAB6NzC...P38/oqQv description**|
   | `vmJumpboxOSType` | The type of OS for the deployed jump box. | **linux** | **windows** |
   | `vmAuthenticationType` | The type of authentication method for the deployed jump box if Linux. | **password** | **sshPublicKey** |
   | `vmJumpBoxSubnetAddressPrefix` | CIDR to use for the jump box subnet. must be a subset of the hub CIDR ranges. | **10.1.2.32/27** | **10.100.3.128/25** |
   | `enableApplicationInsights` | Controls if Application Insights is deployed and configured. | **true** | **false** |
   | `aRecords` | A Records for App Gateway DNS | **[]** | **[]** |
   | `appGatewayCertificatePath` | App Gateway Certificate Path | **configuration/acahello.demoapp.com.pfx** | **configuration/acahello.demoapp.com.pfx** |
   | `appGatewayCertificateKeyName` | App Gateway Certificate Key Name | **agwcert** | **agwcert** |
   | `appGatewayFQDN` | App Gateway FQDN | **acahello.demoapp.com** | **acahello.demoapp.com** |
   | `deployHelloWorldSample` | Deploy a simple, sample application to the infrastructure. If you prefer to deploy the more comprehensive, Dapr-enabled sample app, this needs to be disabled | **true** | **false**, because you plan on deploying the Dapr-enabled application instead. |
   | `helloWorldContainerAppName` | Name for ACA | **none** | **ca-hello-world** |
   | `clientIP` | If you'd like to deploy the architecture with Application Gateway without having to deploy Application Gateway separately, this should be set to the Public IP address of the machine executing the deployment | **""** | 192.168.1.1 |
   | `workloadProfiles` | If you'd like to use workload profiles, you need to set field which is an array of objects with name, workload_profile_type, minimum_count and maximum_count fields. | *none* | `[{`<br>`name = "general-purpose", `<br>` workload_profile_type = "D4", `<br>` minimum_count = 1,  `<br>` maximum_count = 3 `<br>` }]` |


### Deploy

Before deploying, you need to decide how you would like to deploy the solution with Application Gateway. You have two options:
- If you provide your client IP address, the Public IP address of the machine executing the Terraform deployment, it will be added to the Network ACL for the KeyVault used to house the Application Gateway certificate and it will allow you to proceed through the entire deployment. 
- If you would like to keep the KeyVault fully private, you will need to comment out the Application Gateway module in the [main.tf](main.tf) and leave the clientIP value blank in your tfvars file. Follow the [instructions for deploying Application Gateway separately on your jump box](../terraform/modules/06-application-gateway/main.tf). 

### :world_map: Choose your deployment experience.

   This reference implementation comes with *two* implementation deployment options. They all result in the same resources and architecture, they simply differ in their user experience; specifically how much is abstracted from your involvement.

   - Follow the "[**Standalone deployment guide**](#standalone-deployment-guide)" if you'd like to simply configure a set of parameters and execute a single CLI command to deploy.

     *This will be your simplest deployment approach, but also the most opaque. This is optimized for "cut to the end."*

   - Follow the "[**Step-by-step deployment guide**](#step-by-step-deployment-guide)" if you'd like to walk through the deployment at a slower, more deliberate pace.

     *This will approach will allow you to see the deployment evolve over time, which might give you an insight into the various roles and people in your organization that you need to engage when bringing your workload in this architecture to Azure. This is optimized for "learning."*


### 1. Standalone deployment guide

You can deploy the complete landing zone in a single subscription, by using the [main.tf](main.tf) template file and the accompanying [terraform.tfvars](terraform.tfvars) parameter file. You need first to check and customize the parameter file (parameters are described below) and then decide whether you intend to deploy the simple [Hello World App](modules/05-hello-world-sample-app/README.md) or the more comprehensive, Dapr-enabled [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md). If you intend to deploy the [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md), we recommend that you set the variable `deployHelloWorldSample` to `false`.

#### Provide parameters required for deployment
1. Review the available variables with their descriptions and default values in the [variables.tf](./variables.tf) file.
2. Provide any custom values to the defined variables by creating a `terraform.tfvars` file in this [directory](terraform.tfvars)
    * [TF Docs: Variable Definitions (.tfvars) Files](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)

> [!NOTE]
> If you are using Azure CLI authentication that is not a service principal or OIDC, the [AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide) now requires setting the `subscription_id` in the provider. Running the following command in your Bash terminal before moving on to the next commands. 
> 
> `export ARM_SUBSCRIPTION_ID=00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

#### Bash shell (i.e. inside WSL2 for windows 11, or any linux-based OS)
``` bash
terraform init `
    --backend-config=resource_group_name="tfstate" `
    --backend-config=storage_account_name=<Your TF State Store Storage Account Name> `
    --backend-config=container_name="tfstate" `
    --backend-config=key="acalza/terraform.state"
terraform plan --var-file terraform.tfvars -out tfplan
terraform apply tfplan
```
#### Deploy the Dapr-based workload. *Optional.*

   If you chose to set `deployHelloWorldSample` to **false**, then proceed to deploy the Dapr-based workload by following the instructions at:

   :arrow_forward: [Fine Collection Sample App](sample-apps/java-fine-collection-service/docs/02-container-apps.md)


#### :broom: Clean up resources

When you are done exploring the resources created by the Standalone deployment guide, use the following command to remove the resources you created.

```bash
terraform destroy --var-file=terraform.tfvars
```

### 2. Step-by-step deployment guide

These instructions are spread over a series of dedicated pages for each step along the way. With this method of deployment, you can leverage the step-by-step process considering where possibly different teams (devops, network, operations etc) with different levels of access, are required to coordinate and deploy all of the required resources.

:arrow_forward: This starts with [Deploy the hub networking resources](./modules/01-hub/README.md).
