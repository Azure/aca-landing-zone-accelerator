# Scenario 1: Azure Container Apps - Internal environment secure baseline

This reference implementation demonstrates a *secure baseline infrastructure architecture* for a microservices workload deployed into [Azure Container Apps](https://learn.microsoft.com/azure/container-apps). Specifically this scenario addresses deploying Azure Container Apps into a [virtual network](https://learn.microsoft.com/azure/container-apps/vnet-custom-internal), and has no public endpoint.

Azure Container Apps-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the cluster infrastructure, and finally the workload itself. This reference implementation steps are created by keeping that in mind. Also, be aware our primary purpose is to illustrate the topology and decisions of a baseline cluster. We feel a "step-by-step" flow will help you learn the pieces of the solution and give you insight into the relationship between them Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (team roles, organizational standards, tooling, etc), and must be implemented as appropriate for your needs.

By the end of this deployment guide, you would have deployed an "internal environment" Azure Container Apps cluster. You will will also deploying a sample web app. This implementation is not expected to be your first exposure to Azure Container Apps, if you're looking for introductory material, please complete the [Implement Azure Container Apps](https://learn.microsoft.com/training/modules/implement-azure-container-apps/) training module on Microsoft Learn.

![Architectural diagram showing an Azure Container Apps deployment in a spoke virtual network.](../../docs/media/acaInternal/aca-internal.png)

## Core architecture components

- Azure Container Apps
- Azure Virtual Networks (hub-spoke)
- Azure Container Registry
- Azure Bastion
- Azure Application Gateway (Web Application Firewall)
- Azure Key Vault
- Azure Private DNS Zones
- Log Analytics Workspace

## Deploy the reference implementation

This reference implementation is provided with the following infrastructure as code options. Select the one you are interested in. They both deploy the same implementation.

:arrow_forward: [Bicep](./bicep)

:arrow_forward: [Terraform](./Terraform) *(coming soon)*
