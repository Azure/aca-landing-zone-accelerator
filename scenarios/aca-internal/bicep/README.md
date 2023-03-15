# Enterprise Scale for ACA Internal  - Bicep Implementation

A deployment of ACA-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the cluster infrastructure, and finally the workload itself. This reference implementation  can be used with two different ways, as explained next. The primary purpose of this implementation is to illustrate the topology and decisions of a secure baseline Azure COntainer Apps environment. 

TODO: Centralized Resource naming following CAF recommendations

## Prerequisites 
- Clone this repo
- Install [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Install [bicep tools](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install)



### Standalone Deployment Guide

You can deploy the complete landing zone in a single subscription, by using the main.bicep file in the root of this folder. If you want to deploy with one of the sample applications, you can find the documentation in the [sample-apps](sample-apps/) folder. Each application has its own bicep file and parameters file and describe how to deploy them in an existing landing zone or with a new one.

To deploy the complete landing zone, first review the parameters in [main.parameters.jsonc](./main.parameters.jsonc). 

Before deploying the Bicep IaC artifacts, you need to review and customize the values of the parameters in the [main.parameters.jsonc](main.parameters.jsonc) file. 

The table below summurizes the avaialble parameters and the possible values that can be set. 

TODO: Change
| Name | Description | Example | 
|------|-------------|---------|
|applicationName|A suffix that will be used to name the resources in a pattern similar to ` <resourceAbbreviation>-<applicationName> ` . Must be up to 10 characters long, alphanumeric with dashes|app-svc-01|
|location|Azure region where the resources will be deployed in||
|environment|Required. The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.||
|vnetHubResourceId|If empty, then a new hub will be created. If you select not to deploy a new Hub resource group, set the resource id of the Hub Virtual Network that you want to peer to. In that case, no new hub will be created and a peering will be created between the new spoke and and existing hub vnet|/subscriptions/<subscription_id>/ resourceGroups/<rg_name>/providers/ Microsoft.Network/virtualNetworks/<vnet_name>|
|firewallInternalIp|If you select to create a new Hub, the UDR for locking the egress traffic will be created as well, no matter what value you set to that variable. However, if you select to connect to an existing hub, then you need to provide the internal IP of the azure firewal so that the deployment can create the UDR for locking down egress traffic. If not given, no UDR will be created||
|hubVnetAddressSpace|If you deploy a new hub, you need to set the appropriate CIDR of the newly created Hub virtual network|10.242.0.0/20|
|subnetHubFirewallAddressSpace|CIDR of the subnet that will host the azure Firewall|10.242.0.0/26|
|subnetHubBastionddressSpace|CIDR of the subnet that will host the Bastion Service|10.242.0.64/26|
|spokeVnetAddressSpace|CIDR of the spoke vnet that will hold the app services plan and the rest supporting services (and their private endpoints)|10.240.0.0/20|
|subnetSpokeAppSvcAddressSpace|CIDR of the subnet that will hold the app services plan|10.240.0.0/26|
|subnetSpokeDevOpsAddressSpace|CIDR of the subnet that will hold devOps agents etc|10.240.10.128/26|
|subnetSpokePrivateEndpointAddressSpace|CIDR of the subnet that will hold the private endpoints of the supporting services|10.240.11.0/24|
|webAppPlanSku|Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. select one from: 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ' ||
|webAppBaseOs|The OS for the App service plan. Two options available: Windows or Linux||
|resourceTags|Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)|"resourceTags": {<br>         "value": { <br>               "deployment": "bicep", <br>  "key1": "value1" <br>           } <br>         } |
|sqlServerAdministrators|The Azure Active Directory (AAD) administrator group used for SQL Server authentication.  The Azure AD group  must be created before running deployment. This has three values that need to be filled, as shown below <br> **login**: the name of the AAD Group <br> **sid**: the object id  of the AAD Group <br> **tenantId**: The tenantId of the AAD ||

Then you can use the following command to deploy the landing zone:

```azcli
az deployment sub create \
    --template-file main.bicep \
    --location <LOCATION> \
    --name <DEPLOYMENT_NAME> \
    --parameters ./main.parameters.jsonc
```
 where `<LOCATION>` is the location where you want to deploy the landing zone and `<DEPLOYMENT_NAME>` is the name of the deployment.

### End-to-End Deployment with Sample Application

This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment. Please read carrefully the documentation of each step before deploying it. All bicep templates parameters are documented in the bicep templates.

0. Preqs - Clone this repo, install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), install [Bicep tools](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
1. [Hub](modules/01-hub/README.md)
2. [Spoke](modules/02-spoke/README.md)
3. [Supporting Services](modules/03-supporting-services/README.md)
4. [ACA Environment](modules/04-container-apps-environment/README.md)
5. [Hello World Sample Container App (Optional)](modules/05-hello-world-sample-app/README.md)
6. [Application Gateway](modules/06-application-gateway/README.md) or [Front Door](modules/06-front-door/README.md)  

### Cleanup

To remove the resources created by this landing zone, you can use the following command:

```azcli
az group delete -n <RESOURCE_GROUP_NAME> --yes
```

Where `<RESOURCE_GROUP_NAME>` is the name of the resource group where the resources were deployed. For each resource group created by the landing zone: at least the hub and the spoke. You can also delete the resource group where the supporting services were deployed, if you created one.
