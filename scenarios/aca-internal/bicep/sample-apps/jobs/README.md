# Sample App: Jobs

The purpose of this sample app is to demonstrate the usage of the [Jobs feature](https://learn.microsoft.com/en-us/azure/container-apps/jobs?tabs=azure-cli) with Azure Container Apps.

## Overview

The solution deploys 3 different [types](https://learn.microsoft.com/en-us/azure/container-apps/jobs?tabs=azure-cli#job-trigger-types) of Jobs, a manual triggered, a schedule triggered and an event trigered one with basic functionality of calculating the Fibonacci number for a given range of numbers.

1. Login to the VM using Bastion
2. Install pre-reqs azure CLI, Docker client
3. git clone repository
4. git checkout feature/jobs
4. docker build to acr
5. Deploy jobs to container apps environment

az deployment group create --resource-group rg-lzaaca-udr-spoke-dev-neu --name jobs-deployment --template-file main.bicep --parameters workloadName=lzaacajobs containerAppsEnvironmentName='cae-lzaaca-udr-dev-neu' acrName=crlzaacaudr6dnqbdevneu managedIdentityName='id-crlzaacaudr6dnqbdevneu-AcrPull' workspaceId='/subscriptions/c3caea05-d40f-4cd5-a694-68a5bef3904d/resourcegroups/rg-lzaaca-udr-spoke-dev-neu/providers/microsoft.operationalinsights/workspaces/log-lzaaca-udr-dev-neu' spokeVNetName='vnet-lzaaca-udr-dev-neu-spoke' spokePrivateEndpointsSubnetName='snet-pep' hubVNetId='/subscriptions/c3caea05-d40f-4cd5-a694-68a5bef3904d/resourceGroups/rg-lzaaca-udr-hub-dev-neu/providers/Microsoft.Network/virtualNetworks/vnet-dev-neu-hub'