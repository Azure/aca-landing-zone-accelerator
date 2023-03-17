# Azure Container Apps Landing Zone Accelerator

Azure Landing Zone Accelerators are architectural guidance, reference architecture, reference implementations and automation packaged to deploy workload platforms on Azure at Scale and aligned with industry proven practices.

Azure Container apps Landing Zone Accelerator represents the strategic design path and target technical state for an Azure Container Apps Service deployment. 

This repository provides packaged guidance for customer scenarios, reference architecture, reference implementation, tooling, design area guidance, sample application deployed after provisioning the infrastructure using the accelerator. The architectural approach can be used as design guidance for greenfield implementation and as an assessment for brownfield customers already using containerized apps. 

![ACA Hub and Spoke architecture](./docs/media/acaInternal/aca-internal.png)

## Enterprise-Scale Architecture

The enterprise architecture is broken down into key design areas, where you can find the links to each at:
| Design Area|Considerations and Recommendations|
|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations and Recommendations](/docs/design-areas/identity.md)
| Network Topology and Connectivity|[Design Considerations and Recommendations](/docs/design-areas/networking.md)
| Management and Monitoring|[Design Considerations and Recommendations](/docs/design-areas/management.md)
| Security, Governance, and Compliance|[Design Considerations and Recommendations](/docs/design-areas/security.md)

## Enterprise-Scale Reference Implementation

In this repo you will find reference implementations with supporting *Infrastructure as Code* artifacts. Currently we support the below scenario

:arrow_forward: [Scenario 1: Secure Baseline - Azure Container Apps Internal](scenarios/aca-internal/README.md), implemented with [Bicep](scenarios/aca-internal/bicep/). 

More reference implementations will be added as they become available.


## Got a feedback
Please leverage issues if you have any feedback or request on how we can improve on this repository.

## Data Collection
The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkId=521839. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

## Telemetry Configuration
Telemetry collection is on by default.

To opt-out, set the variable `enableTelemetry` to `false` in [Bicep parameter file](scenarios/aca-internal/bicep/main.parameters.jsonc).

## Contributing
See more at [Contributing](CONTRIBUTING.md)

## Trademarks
This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.
