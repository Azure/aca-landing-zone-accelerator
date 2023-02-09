# Azure Container Apps Landing Zone Accelerator

Azure Landing Zone Accelerators are architectural guidance, reference architecture, reference implementations and automation packaged to deploy workload platforms on Azure at Scale and aligned with industry proven practices.

Azure Container apps Landing Zone Accelerator represents the strategic design path and target technical state for an Azure Container Apps Service deployment. 

This repository provides packaged guidance for customer scenarios, reference architecture, reference implementation, tooling, design area guidance, sample application deployed after provisioning the infrastructure using the accelerator. The architectural approach can be used as design guidance for greenfield implementation and as an assessment for brownfield customers already using containerized apps. 

## Enterprise-Scale Architecture

The enterprise architecture is broken down into key design areas, where you can find the links to each at:
| Design Area|Considerations and Recommendations|
|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations and Recommendations](/docs/design-areas/identity.md)
| Network Topology and Connectivity|[Design Considerations and Recommendations](/docs/design-areas/networking.md)
| Management and Monitoring|[Design Considerations and Recommendations](/docs/design-areas/operationsManagement.md)
| Security, Governance, and Compliance|[Design Considerations and Recommendations](/docs/design-areas/security.md)

## Steps of Implementation for Applications on Azure Container Apps

A deployment of ACA-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the cluster infrastructure, and finally the workload itself. This reference implementation steps are created by keeping that in mind. Also, be aware our primary purpose is to illustrate the topology and decisions of a baseline cluster. We feel a "step-by-step" flow will help you learn the pieces of the solution and give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (team roles, organizational standards, tooling, etc), and must be implemented as appropriate for your needs.

![ACA Hub and Spoke architecture](./docs/media/acaInternal/aca-internal.png)

## Accounting for Separation of Duties

While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials.

## Keeping It As Simple As Possible

The code here is purposely written to avoid loops, complex variables and logic. In most cases, it is resource blocks, small modules and limited variables, with the goal of making it easier to determine what is being deployed and how they are connected. Resources are broken into separate files for future modularization or adjustments as needed by your organization.

## Getting Started

This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment.

1. Preqs - Clone this repo, install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), install [bicep tools](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
2. [Creation of Hub Network & its respective Components](scenarios/acaInternal/bicep/01-network-hub.md))
3. [Creation of Spoke Network & its respective Components](./scenarios/acaInternal/bicep/02-network-lz.md)
4. [Creation of Supporting Components for ACA](./scenarios/acaInternal/bicep/03-aks-supporting.md)
5. [Creation of ACA Environment](./scenarios/acaInternal/bicep/04-aca-env.md)
6. [Creation of Azure container apps](./scenarios/acaInternal/bicep/05-aca-apps.md)

## Got a feedback
Please leverage issues if you have any feedback or request on how we can improve on this repository.

## Data Collection
The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkId=521839. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

## Telemetry Configuration
Telemetry collection is on by default.

To opt-out, set the variable enableTelemetry to false in Bicep/ARM file and disable_terraform_partner_id to false on Terraform files.

## Contributing
See more at [Contributing](CONTRIBUTING.md)

## Trademarks
This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.
