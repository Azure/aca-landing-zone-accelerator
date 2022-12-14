# ACA landing zone accelerator - External for Bicep

## Keeping It As Simple As Possible

The code here is purposely written to avoid loops, complex variables and logic. In most cases, it is resource blocks, small modules and limited variables, with the goal of making it easier to determine what is being deployed and how they are connected. Resources are broken into separate files for future modularization or adjustments as needed by your organization.

## Getting Started

This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment.

1. Prerequisites: Clone this repo, install [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), install [Bicep tools](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install)
2. [Creation of several shared services (Container Registry, KeyVault) & ACA Identity](./01-aca-supporting.md)
3. [Creation of Container Apps Environment & its respective Components](./02-aca-env.md)
4. [Creation of a Container App & its respective Components](./03-aca-apps.md)
