# Azure Container Apps Landing Zone Accelerator - Management & Operations

You can work toward operational excellence and customer success by properly designing your Azure Container Apps (ACA) solution with management and monitoring in mind.

---
## Design Area considerations

- Understand [ACA limits](https://learn.microsoft.com/azure/container-apps/quotas).

- Consider isolating workloads at the network, compute, monitor or data level.

- Understand ways to control resource consumption by workloads.

- Using health probes, can help ACA determine the health of your workloads and take automated actions in case of deteriorating application health.

- To securely establish connections to external services, [DAPR](https://learn.microsoft.com/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml) can be used at the Azure Container Apps Environment level.

- Logging and monitoring are fundamental practices in operating an application. Having the right instrumentation in place allows you to troubleshoot ongoing issues, as well as understand if your operational targets are being met.

- Receiving proper [alerts](https://learn.microsoft.com/azure/container-apps/log-monitoring?tabs=bash) during critical application and system events will ensure operational staff can act swiftly in case of anomalies. 

- Implementing a proper [scaling strategy](https://learn.microsoft.com/azure/container-apps/scale-app?pivots=azure-cli) will ensure there is enough capacity available to handle traffic to your solution, while minimizing unused capacity. Solutions built on Azure Container Apps can be scaled using typical CPU or memory metrics, but also allow more advanced scaling strategies using KEDA. For example, the solution may be scaled to accommodate the number of messages on an Azure Service Bus or the number of concurrent TCP connections.

- Azure Container Apps uses Envoy as a [network proxy](https://learn.microsoft.com/azure/container-apps/network-proxy). This allows flexibility in setting up routing and encryption.

- Specific requirements around Business Continuity and Disaster Recovery should be addressed for the Azure Container Apps platform. These requirements relate to recovery time objective (RTO) and recovery point objective (RPO). Your first step is to define a service-level agreement (SLA) for your infrastructure and application. Learn about the [SLA for Azure Container Apps](https://azure.microsoft.com/support/legal/sla/container-apps/v1_0/). See the **SLA details** section for information about monthly uptime calculations.
- Depending on the specific requirements for your application, high-availability measures may need to be taken to ensure continued operation in case of irregularities in the underlying Azure platform. In Azure, the various zones and regions allow you to build solutions for high-availability:
  - [Availability Zones](https://learn.microsoft.com/azure/container-apps/disaster-recovery) are fault isolation constructs in Azure datacenter design. Each zone has its own power, network and cooling to minimize the chance of outages spreading across zones. To leverage Availability Zones, each Azure resources can be deployed either to a specific zone ("zonal") or to all zones ("zone redundant").
  - Multi-region solutions provide the highest level of fault isolation and the highest reliability, but are often more difficult to implement because of the higher latency between the geographic regions consequent data-replication delays. For more information on multi-region design, the [Azure Mission Critical documentation](https://learn.microsoft.com/azure/architecture/framework/mission-critical/mission-critical-application-design) is a good starting point.

- A key factor in successful operations is _automation_. Azure DevOps and GitHub provide ways of managing the development, build and deployment process in a fully automated way. This minimizes the chance of human error and potential downtime for your users. 

---
## Design Area Recommendations

- Create distinct ACA environments if you need full resource isolation. Don't use revisions to create tenant specific container apps. [ACA in multitenant solution](https://learn.microsoft.com/azure/architecture/guide/multitenant/service/container-apps).

- Use [containers cpu and memory resources requests limits](https://learn.microsoft.com/azure/container-apps/containers) to manage the compute and memory resources within an ACA environment. Container default limits are 2 vCPU and 4 GiB for compute and memory respectively.

- Add health probes to your container apps. Make sure pods contain `livenessProbe`, `readinessProbe`, and `startupProbe`. [ACA health probes](https://learn.microsoft.com/azure/container-apps/health-probes?tabs=arm-template).

- The health probe calls an endpoint on your application, such as /health. This endpoint should return a success status code (HTTP 2xx) when the status is healthy. Ideally, this endpoint also checks the health of required downstream components (databases, storage, messaging). Ensure that the downstream health response is cached for a short period to prevent a continuous cascade of health checks flooding your solution.

- ACA logs consist of two different categories. For each of these logs, understand what important events look like (warnings, errors, critical messages) and create a Log Analytics query with an alert for them:
  - Application logs generated by containers console output (stdout/stderr) messages. When Dapr is enabled, console output will contain both application container and Dapr sidecar messages. Review [ACA Log monitoring](https://learn.microsoft.com/azure/container-apps/log-monitoring?tabs=bash) to understand how to query logs using log analytics.
  - System logs generated by Azure Container Apps.

- When Dapr is enabled, make sure to configure [DaprAIInstrumentationKey](https://learn.microsoft.com/azure/container-apps/environment) at the ACA environment level to visualize container apps distributed tracing in the Azure Application Insights application map.

- Consider using the Application Insights SDK for application telemetry as [auto-instrumentation agent](https://learn.microsoft.com/azure/container-apps/observability) is not supported yet.

- In case of high-availability requirements, ensure the use of Availability Zones is enabled on all resources. Ensure that not only your Container Apps are zone redundant, but also adjacent services required to fulfil requests, such as databases, storage and messaging services.

- For disaster recovery (DR) purposes, ensure that your application data and source code are available in more than one Azure region. For example, Azure Storage accounts allow geo-replicated storage and Azure SQL Databases allow read-replicas to be placed in other regions. 

- Use end-to-end automation to build and deploy your Azure Container Apps applications.

- Store your container images in [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication) and geo-replicate the registry to each ACA region.

- Create and test a disaster recovery plan regularly using key failure scenarios.[Testing backup and disaster recovery](https://learn.microsoft.com/azure/architecture/framework/resiliency/backup-and-recovery)
