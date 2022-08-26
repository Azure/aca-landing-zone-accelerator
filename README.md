# Enterprise Scale for ACA - Private 

## Steps of Implementation for Applications on Azure Container Apps

A deployment of ACA-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the cluster infrastructure, and finally the workload itself. This reference implementation steps are created by keeping that in mind. Also, be aware our primary purpose is to illustrate the topology and decisions of a baseline cluster. We feel a "step-by-step" flow will help you learn the pieces of the solution and give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (team roles, organizational standards, tooling, etc), and must be implemented as appropriate for your needs.

![ACA Hub and Spoke architecture](./Assets/ACA-Landingzone.jpg)

## Accounting for Separation of Duties

While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials.

## Keeping It As Simple As Possible

The code here is purposely written to avoid loops, complex variables and logic. In most cases, it is resource blocks, small modules and limited variables, with the goal of making it easier to determine what is being deployed and how they are connected. Resources are broken into separate files for future modularization or adjustments as needed by your organization.

## Getting Started

This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment.

1. Preqs - Clone this repo, install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), install [Bicep tools](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
2. [Creation of Hub Network & its respective Components](./01-network-hub.md)
3. [Creation of Spoke Network & its respective Components](./02-network-lz.md)
4. [Creation of Supporting Components for ACA](./03-aks-supporting.md)
5. [Creation of ACA Environment](./04-aca-env.md)
6. [Creation of Azure container apps](./05-aca-apps.md)

