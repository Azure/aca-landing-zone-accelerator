# ACA Internal
> 
This scenario demonstrates a secure baseline on how to deploy a microservices workload securely into an [internal](https://learn.microsoft.com/en-us/azure/container-apps/vnet-custom-internal?tabs=bash&pivots=azure-portal) environment where the environment has no public endpoint. 

A deployment of ACA-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the cluster infrastructure, and finally the workload itself. This reference implementation steps are created by keeping that in mind. Also, be aware our primary purpose is to illustrate the topology and decisions of a baseline cluster. We feel a "step-by-step" flow will help you learn the pieces of the solution and give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (team roles, organizational standards, tooling, etc), and must be implemented as appropriate for your needs.

By the end of this, you would have deployed a ACA Internal Environment. We will also be deploying a sample web app. Check out the [Introduction to Azure Container Apps on Azure](https://learn.microsoft.com/en-us/azure/container-apps/) Training path on Microsoft Learn  for some intermediate level training on ACA.

For this scenario, we will have various IaC technology that you can choose from depending on your preference. At this time only the Bicep versions are available. Below is an architectural diagram of this scenario.

![Architectural diagram for the ACA Internal scenario.](../../docs/media/acaInternal/aca-internal.png)

## Core architecture components
* Azure Container Apps
* Azure Virtual Networks (hub-spoke)
* Azure Container Registry
* Azure Bastion
* Azure Application Gateway with WAF
* Azure Key vault
* Azure Private DNS Zones
* Log Analytics Workspace

## Next
Pick one of the IaC options below and follow the instructions to deploy the ACA reference implementation.

:arrow_forward: [Bicep](./bicep) 

:arrow_forward: [Terraform](./Terraform) (coming soon)
