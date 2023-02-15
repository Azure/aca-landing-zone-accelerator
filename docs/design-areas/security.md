<!--Begining of Landing Zone Accelerator - Azure Container Apps -Security.MD v1 -->

## Security considerations for Azure Container Apps Landing Zone Accelerator

This ReadMe File provides design considerations and recommendations for Security when you use Azure Container Apps landing zone accelerator.  It walks through aspects of Azure Contianer Apps (ACA) security governance to think about before implementing any solution.

Most of this content is technology-agnostic, because implementation varies among customers. The ReadMe File focuses on how to implement solutions using Azure and open-source software. The decisions made when you create an enterprise-scale landing zone can partially predefine your governance. It's important to understand governance principles because of the effect of the decisions made.

The security profile summarizes high-impact behaviors of Azure Container Apps, which may result in increased security considerations.  When a workload or the landing zones that hosts it require access to any sensitive data or critical systems, it's important to protect the data and assets.

### Azure Container  Apps Landing Zone - Topology

![ACA Hub and Spoke architecture](./docs/media/acaInternal/aca-internal.png)

### Azure Container Apps Landing Zone - Azure Components
Pending 
| Component | Version | Location |
|-------------|---------------|---------------|

-------
Cloud security is also an incremental process instead of just a static destination. Focus on objectives and key results when envisioning a security end state. Map concepts, frameworks, and standards to the disciplines in the CAF secure methodology alongside mapping to roles and responsibilities for human discipline. The secure methodology provides guidance.

### Design Considerations

### 1. Azure Security Baseline for Azure Container Apps Service
<!-- <content> --> 
<p>This security baseline applies guidance from the <a href="/en-us/security/benchmark/azure/overview" data-linktype="absolute-path">Microsoft cloud security benchmark version 1.0</a> to Azure Container Apps. The Microsoft cloud security benchmark provides recommendations on how you can secure your cloud solutions on Azure. The content is grouped by the security controls defined by the Microsoft cloud security benchmark and the related guidance applicable to Azure Container Apps.</p>
<p>You can monitor this security baseline and its recommendations using Microsoft Defender for Cloud. Azure Policy definitions will be listed in the Regulatory Compliance section of the Microsoft Defender for Cloud dashboard.</p>
<p>When a feature has relevant Azure Policy Definitions, they are listed in this baseline to help you measure compliance to the Microsoft cloud security benchmark controls and recommendations. Some recommendations may require a paid Microsoft Defender plan to enable certain security scenarios.</p>
<div class="NOTE">
<p>Note</p>
<p><strong>Features</strong> not applicable to Azure Container Apps have been excluded. To see how Azure Container Apps completely maps to the Microsoft cloud security benchmark, see the <strong><a href="https://github.com/MicrosoftDocs/SecurityBenchmarks/tree/master/Azure%20Offer%20Security%20Baselines/3.0/azure-container-apps-azure-security-benchmark-v3-latest-security-baseline.xlsx" data-linktype="external">full Azure Container Apps security baseline mapping file</a></strong>.</p></div>

### 2. Security Profile
<p>Ensure that security is an organizational concern and not siloed into a single group. <a href="../../secure/security-integration" data-linktype="relative-path">Security integration</a> provides you with guidance on how to integrate security into everyone's role while minimizing friction with business processes. Specific guidance includes:</p>
<ul>
<li><a href="../../secure/security-integration#normalize-relations" data-linktype="relative-path">Normalizing relations</a>: Ensure all teams are integrated with security teams and have a shared understanding of security goals. Further, work to find the right level of security controls, ensuring the controls don't outweigh business value.</li>
<li><a href="../../secure/security-integration#integrate-with-it-and-business-operations" data-linktype="relative-path">Integrate with IT and business operations</a>: Balance the implementation of security updates and mapping how all security processes affect current business impact, and potential security risk in the future.</li>
<li><a href="../../secure/security-integration#integrate-security-teams" data-linktype="relative-path">Integrate security teams</a>: Avoid operating in silos by responding to active threats and continuously improving the security posture of the organization by practicing security as a dynamic discipline.</li>
</ul></p>

<p>Establish <a href="../../secure/security-operations" data-linktype="relative-path">security operations</a> by reducing risk, rapidly responding, and recovery to protect your organization and follow the security discipline of the DevOps process.</p>
<ul>
<li><a href="../../secure/security-operations#people-and-process" data-linktype="relative-path">People and process</a>: Create a culture to empower people with tools to enable them as your most valuable asset and diversify your thinking portfolio by including and training non-technical people with strong backgrounds in forensic investigation roles.</li>
<li><a href="../../secure/security-operations#security-operations-model" data-linktype="relative-path">Security operations model</a>: Focus on the outcomes of incident management, incident preparation, and threat intelligence. Delegate the outcomes between subteams to triage, investigate, and hunt on high volume and complex incidents.</li>
<li><a href="../../secure/security-operations#secops-business-touchpoints" data-linktype="relative-path">SecOps business touchpoints</a>: Interact with business leadership in order to inform major incidents and determine impact of critical systems. Continuously joint practice response to reduce organizational risk.</li>
<li><a href="../../secure/security-operations#secops-modernization" data-linktype="relative-path">SecOps modernization</a>: Evolve security operations by following trends involving platform coverage, identity-centric security, IoT and OT devices, and relevant telemetry from the cloud.</li>
</ul></p>
<p>Perform oversight and monitoring with <a href="../../secure/security-governance" data-linktype="relative-path">security governance</a> for sustaining and improving security posture over time by using business goals and risk to determine the best direction for security.</p>
<ul>
<li><a href="../../secure/security-governance#compliance-and-reporting" data-linktype="relative-path">Compliance and reporting</a>: Have both external and internal security policies meet mandatory requirements in a given industry.</li>
<li><a href="../../secure/security-governance#architecture-and-standards" data-linktype="relative-path">Architecture and standards</a>: Create a unified view across your enterprise estate as most enterprises are a hybrid environment that includes both on-premises and cloud resources.</li>
<li><a href="../../secure/security-governance#security-posture-management" data-linktype="relative-path">Security posture management</a>: Plan for governance to monitor security standards, provide guidance, and improve processes. Maintain agility by driven governance through policy and continuous improvement.</li>
<li><a href="../../secure/security-governance#governance-and-protection-disciplines" data-linktype="relative-path">Governance and protection disciplines</a>: Apply security controls and provide feedback to identify the best solutions.</li>
<li><a href="../../secure/security-governance#governance-and-security-operations" data-linktype="relative-path">Governance and security operations</a>: Ensure that lessons learned from incidents are integrated into security operations and governance.</li>
</ul></p>

The security profile summarizes high-impact behaviors of Azure Container Apps, which may result in increased security considerations.</p>
<table>
<thead>
<tr>
<th>Service Behavior Attribute</th>
<th>Value</th>
</tr>
</thead>
<tbody>
<tr>
<td>Product Category</td>
<td>Containers</td>
</tr>
<tr>
<td>Customer can access HOST / OS</td>
<td>No Access</td>
</tr>
<tr>
<td>Service can be deployed into customer's virtual network</td>
<td>True</td>
</tr>
<tr>
<td>Stores customer content at rest</td>
<td>True</td>
</tr>
</tbody>
</table>


<h3 id="privileged-access">3. Privileged access</h3>
<p><em>For more information, see the <a href="../mcsb-privileged-access" data-linktype="relative-path">Microsoft cloud security benchmark: Privileged access</a>.</em></p>
<h4 id="pa-1-separate-and-limit-highly-privilegedadministrative-users">3.1 - PA-1: Separate and limit highly privileged/administrative users</h4>
<h4 id="features-6">Features</h4>
<h5 id="local-admin-accounts">Local Admin Accounts</h5>
<p><strong>Description</strong>: Service has the concept of a local administrative account. <a href="/en-us/security/benchmark/azure/security-controls-v3-privileged-access#pa-1-separate-and-limit-highly-privilegedadministrative-users" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="pa-7-follow-just-enough-administration-least-privilege-principle">3.2 - PA-7: Follow just enough administration (least privilege) principle</h4>
<h4 id="features-7">Features</h4>
<h5 id="azure-rbac-for-data-plane">Azure RBAC for Data Plane</h5>
<p><strong>Description</strong>: Azure Role-Based Access Control (Azure RBAC) can be used to managed access to service's data plane actions. <a href="/en-us/azure/role-based-access-control/overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="pa-8-determine-access-process-for-cloud-provider-support">3.3 - PA-8: Determine access process for cloud provider support</h4>
<h4 id="features-8">Features</h4>
<h5 id="customer-lockbox">Customer Lockbox</h5>
<p><strong>Description</strong>: Customer Lockbox can be used for Microsoft support access. <a href="/en-us/azure/security/fundamentals/customer-lockbox-overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>

<h3 id="asset-management">4. Asset management</h3>
<p>Secure business critical <a href="../../secure/asset-protection" data-linktype="relative-path">assets</a>, which include all physical and virtual items by implementing security controls that are unique to each asset type. Consistently execute preventive and detective protection to meet policies, standards and architecture.</p>
<ul>
<li><a href="../../secure/asset-protection#get-secure" data-linktype="relative-path">Get secure</a>: Bring resources up to your organization's latest security standards and policy by applying current controls to brownfield assets and ensuring greenfield assets are set to the most recent standards.</li>
<li><a href="../../secure/asset-protection#stay-secure" data-linktype="relative-path">Stay secure</a>: Practice continuous cloud improvement and plan for upgrading or retiring end-of-life software as business, technology, and security requirements change rapidly.</li>
<li><a href="../../secure/asset-protection#getting-started" data-linktype="relative-path">Get started</a>: Start protecting assets by focusing on well-known cloud resources first and use well-known and proven vendor/industry baselines for your security configuration.</li>
<li><a href="../../secure/asset-protection#key-information" data-linktype="relative-path">Key information</a>: Use key elements of accountable and responsible teams to manage enterprise-wide assets such as cloud elasticity workload needs and design controls to identify best practices. Measure business value of asset protection and favor automated policy to avoid cost and manual repetition.</li>
</ul></p>
<p><em>For more information, see the <a href="../mcsb-asset-management" data-linktype="relative-path">Microsoft cloud security benchmark: Asset management</a>.</em></p>
<h4 id="am-2-use-only-approved-services">4.1 - AM-2: Use only approved services</h4>
<h4 id="features-16">Features</h4>
<h5 id="azure-policy-support">Azure Policy Support</h5>
<p><strong>Description</strong>: Service configurations can be monitored and enforced via Azure Policy. <a href="/en-us/azure/governance/policy/tutorials/create-and-manage" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Use Microsoft Defender for Cloud to configure Azure Policy to audit and enforce configurations of your Azure resources. Use Azure Monitor to create alerts when there is a configuration deviation detected on the resources. Use Azure Policy [deny] and [deploy if not exists] effects to enforce secure configuration across Azure resources.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/policy-reference" data-linktype="absolute-path">Azure Policy built-in definitions for Azure Container Apps</a></p>

<h3 id="posture-and-vulnerability-management">5. Posture and Vulnerability Management</h3>
<p><em>For more information, see the <a href="../mcsb-posture-vulnerability-management" data-linktype="relative-path">Microsoft cloud security benchmark: Posture and vulnerability management</a>.</em></p>
<h4 id="pv-3-establish-secure-configurations-for-compute-resources">5.1 - PV-3: Establish secure configurations for compute resources</h4>
<h4 id="features-19">Features</h4>
<h5 id="custom-containers-images">Custom Containers Images</h5>
<p><strong>Description</strong>: Service supports using user-supplied container images or pre-built images from the marketplace with certain baseline configurations pre-applied. <a href="../security-controls-v3-posture-vulnerability-management#pv-3-define-and-establish-secure-configurations-for-compute-resources" data-linktype="relative-path">Learn more</a></p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: You can pull images from private repositories in Microsoft Azure Container Registry using managed identities for authentication to avoid the use of administrative credentials. You can use a system-assigned or user-assigned managed identity to authenticate with Azure Container Registry.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/managed-identity-image-pull?tabs=azure-cli&amp;pivots=command-line" data-linktype="absolute-path">Azure Container Apps image pull with managed identity</a></p>
<h4 id="pv-5-perform-vulnerability-assessments">5.2 - PV-5: Perform vulnerability assessments</h4>
<h4 id="features-20">Features</h4>
<h5 id="vulnerability-assessment-using-microsoft-defender">Vulnerability Assessment using Microsoft Defender</h5>
<p><strong>Description</strong>: Service can be scanned for vulnerability scan using Microsoft Defender for Cloud or other Microsoft Defender services embedded vulnerability assessment capability (including Microsoft Defender for server, container registry, App Service, SQL, and DNS). <a href="/en-us/azure/defender-for-cloud/deploy-vulnerability-assessment-tvm" data-linktype="absolute-path">Learn more</a></p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not applicable</td>
<td>Not applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Though Container Apps does not support vulnerability assessment performed by Defender for Containers, the Azure Container Registry that may be integrated with Container Apps does support vulnerability assessment.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/defender-for-cloud/defender-for-containers-va-acr" data-linktype="absolute-path">Use Defender for Containers to scan your Azure Container Registry images for vulnerabilities</a></p>

-----


### Design Recommendations
### 1. Network Security
<p><em>For more information, see the <a href="../mcsb-network-security" data-linktype="relative-path">Microsoft cloud security benchmark: Network security</a>.</em></p>
<h4 id="ns-1-establish-network-segmentation-boundaries">1.1 - NS-1: Establish network segmentation boundaries</h4>
<h4  id="features">Features</h4>
<h5  id="virtual-network-integration">Virtual Network Integration</h5>
<p><strong>Description</strong>: Service supports deployment into customer's private Virtual Network (VNet). <a href="/en-us/azure/virtual-network/virtual-network-for-azure-services#services-that-can-be-deployed-into-a-virtual-network" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Deploy the service into a virtual network. Assign private IPs to the resource (where applicable) unless there is a strong reason to assign public IPs directly to the resource.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/networking" data-linktype="absolute-path">Azure Container Apps Virtual Network Integration</a></p>
<h5 id="network-security-group-support">Network Security Group Support</h5>
<p><strong>Description</strong>: Service network traffic respects Network Security Groups rule assignment on its subnets. <a href="/en-us/azure/virtual-network/network-security-groups-overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Use network security groups (NSG) to restrict or monitor traffic by port, protocol, source IP address, or destination IP address. Create NSG rules to restrict your service's open ports (such as preventing management ports from being accessed from untrusted networks). Be aware that by default, NSGs deny all inbound traffic but allow traffic from virtual network and Azure Load Balancers.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/firewall-integration" data-linktype="absolute-path">Securing a custom VNET in Azure Container Apps</a></p>
<h4 id="ns-2-secure-cloud-services-with-network-controls">1.2 - NS-2: Secure cloud services with network controls</h3>
<h4 id="features-1">Features</h4>
<h5 id="disable-public-network-access">Disable Public Network Access</h5>
<p><strong>Description</strong>: Service supports disabling public network access either through using service-level IP ACL filtering rule (not NSG or Azure Firewall) or using a 'Disable Public Network Access' toggle switch. <a href="/en-us/security/benchmark/azure/security-controls-v3-network-security#ns-2-secure-cloud-services-with-network-controls" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Disable public network access by deploying an internal-only container apps environment configuration.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/vnet-custom-internal" data-linktype="absolute-path">Provide a virtual network to an internal Azure Container Apps environment</a></p>


### 2. Identity management
<p>Make an <a href="../../secure/access-control" data-linktype="relative-path">access control</a> strategy that aligns both user experience and security assurances.</p>
<ul>
<li><a href="../../secure/access-control#from-security-perimeter-to-zero-trust" data-linktype="relative-path">From security perimeter to zero trust</a>: Embrace a zero trust approach for access control for establishing and improving security assurances when working in the cloud and using new technology.</li>
<li><a href="../../secure/access-control#modern-access-control" data-linktype="relative-path">Modern access control</a>: Make an access control strategy that is comprehensive, consistent, and flexible. Go beyond a single tactic or technology for multiple workloads, clouds, and various business sensitivity levels.</li>
<li><a href="../../secure/access-control#known-trusted-allowed" data-linktype="relative-path">Known, trusted, allowed</a>: Follow the dynamic three-step process to ensure known authentication, trusting the user or device, and allowing the appropriate rights and privileges for the application, service, or data.</li>
<li><a href="../../secure/access-control#data-driven-access-decisions" data-linktype="relative-path">Data-driven access decisions</a>: Make informed decisions from the diverse data on the users and devices for fulfilling explicit validation.</li>
<li><a href="../../secure/access-control#segmentation-separate-to-protect" data-linktype="relative-path">Segmentation: Separate to protect</a>: Create boundaries as separate segments of an internal environment to contain damages of successful attacks.</li>
<li><a href="../../secure/access-control#isolation-avoid-firewall-and-forget" data-linktype="relative-path">Isolation: Avoid firewall and forget</a>: Design an extreme form of segmentation for business-critical assets that consists of: people, process, and technology.</li>
</ul></p>

<p><em>For more information, see the <a href="../mcsb-identity-management" data-linktype="relative-path">Microsoft cloud security benchmark: Identity management</a>.</em></p>
<h4 id="im-1-use-centralized-identity-and-authentication-system">2.1 - IM-1: Use centralized identity and authentication system</h4>
<h4 id="features-2">Features</h4>
<h5 id="azure-ad-authentication-required-for-data-plane-access">Azure AD Authentication Required for Data Plane Access</h5>
<p><strong>Description</strong>: Service supports using Azure AD authentication for data plane access. <a href="/en-us/azure/active-directory/authentication/overview-authentication" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Use Azure Active Directory (Azure AD) as the default authentication method to control your data plane access.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/authentication-azure-active-directory" data-linktype="absolute-path">Enable authentication and authorization in Azure Container Apps with Azure Active Directory</a></p>
<h5 id="local-authentication-methods-for-data-plane-access">Local Authentication Methods for Data Plane Access</h5>
<p><strong>Description</strong>: Local authentications methods supported for data plane access, such as a local username and password. <a href="/en-us/azure/app-service/overview-authentication-authorization" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="im-3-manage-application-identities-securely-and-automatically">2.2 - IM-3: Manage application identities securely and automatically</h4>
<h4 id="features-3">Features</h4>
<h5 id="managed-identities">Managed Identities</h5>
<p><strong>Description</strong>: Data plane actions support authentication using managed identities. <a href="/en-us/azure/active-directory/managed-identities-azure-resources/overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Feature notes</strong>: Managed Identity is supported for Container Apps and Dapr components but not yet for scale rules on a Container App</p>
<p><strong>Configuration Guidance</strong>: Use Azure managed identities instead of service principals when possible, which can authenticate to Azure services and resources that support Azure Active Directory (Azure AD) authentication. Managed identity credentials are fully managed, rotated, and protected by the platform, avoiding hard-coded credentials in source code or configuration files.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/managed-identity" data-linktype="absolute-path">Using Managed Identity in Azure Container Apps</a></p>
<h5 id="service-principals">Service Principals</h5>
<p><strong>Description</strong>: Data plane supports authentication using service principals. <a href="/en-us/powershell/azure/create-azure-service-principal-azureps" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: There is no current Microsoft guidance for this feature configuration. Please review and determine if your organization wants to configure this security feature.</p>
<h4 id="im-7-restrict-resource-access-based-on-conditions">2.3 - IM-7: Restrict resource access based on conditions</h4>
<h4 id="features-4">Features</h4>
<h5 id="conditional-access-for-data-plane">Conditional Access for Data Plane</h5>
<p><strong>Description</strong>: Data plane access can be controlled using Azure AD Conditional Access Policies. <a href="/en-us/azure/active-directory/conditional-access/overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="im-8-restrict-the-exposure-of-credential-and-secrets">2.4 - IM-8: Restrict the exposure of credential and secrets</h4>
<h4 id="features-5">Features</h4>
<h5 id="service-credential-and-secrets-support-integration-and-storage-in-azure-key-vault">Service Credential and Secrets Support Integration and Storage in Azure Key Vault</h5>
<p><strong>Description</strong>: Data plane supports native use of Azure Key Vault for credential and secrets store. <a href="/en-us/azure/key-vault/secrets/about-secrets" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Feature notes</strong>: For Dapr-enabled Container Apps, customers can leverage Azure Key Vault for secret references. Container Apps Secrets do not support Key Vault references today.</p>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>

<h3 id="data-protection">3. Data protection</h3>
<p><em>For more information, see the <a href="../mcsb-data-protection" data-linktype="relative-path">Microsoft cloud security benchmark: Data protection</a>.</em></p>
<h4 id="dp-1-discover-classify-and-label-sensitive-data">3.1 - DP-1: Discover, classify, and label sensitive data</h4>
<h4 id="features-9">Features</h4>
<h5 id="sensitive-data-discovery-and-classification">Sensitive Data Discovery and Classification</h5>
<p><strong>Description</strong>: Tools (such as Azure Purview or Azure Information Protection) can be used for data discovery and classification in the service. <a href="/en-us/security/benchmark/azure/security-controls-v3-data-protection#dp-1-discover-classify-and-label-sensitive-data" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="dp-2-monitor-anomalies-and-threats-targeting-sensitive-data">3.2 - DP-2: Monitor anomalies and threats targeting sensitive data</h4>
<h4 id="features-10">Features</h4>
<h5 id="data-leakageloss-prevention">Data Leakage/Loss Prevention</h5>
<p><strong>Description</strong>: Service supports DLP solution to monitor sensitive data movement (in customer's content). <a href="/en-us/security/benchmark/azure/security-controls-v3-data-protection#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="dp-3-encrypt-sensitive-data-in-transit">3.3 - DP-3: Encrypt sensitive data in transit</h4>
<h4 id="features-11">Features</h4>
<h5 id="data-in-transit-encryption">Data in Transit Encryption</h5>
<p><strong>Description</strong>: Service supports data in-transit encryption for data plane. <a href="/en-us/azure/security/fundamentals/double-encryption#data-in-transit" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>False</td>
<td>Customer</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: Enable secure transfer in services where there is a native data in transit encryption feature built in. Enforce HTTPS on any web applications and services and ensure TLS v1.2 or later is used. Legacy versions such as SSL 3.0, TLS v1.0 should be disabled. For remote management of Virtual Machines, use SSH (for Linux) or RDP/TLS (for Windows) instead of an unencrypted protocol.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/ingress?tabs=bash" data-linktype="absolute-path">Set up HTTPS or TCP ingress in Azure Container Apps</a></p>
<h4 id="dp-4-enable-data-at-rest-encryption-by-default">3.4 - DP-4: Enable data at rest encryption by default</h4>
<h4 id="features-12">Features</h4>
<h5 id="data-at-rest-encryption-using-platform-keys">Data at Rest Encryption Using Platform Keys</h5>
<p><strong>Description</strong>: Data at-rest encryption using platform keys is supported, any customer content at rest is encrypted with these Microsoft managed keys. <a href="/en-us/azure/security/fundamentals/encryption-atrest#encryption-at-rest-in-microsoft-cloud-services" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>True</td>
<td>Microsoft</td>
</tr>
</tbody>
</table>
<p><strong>Feature notes</strong>: Azure Container Apps leverages Microsoft's default encryption for data at rest.</p>
<p><strong>Configuration Guidance</strong>: No additional configurations are required as this is enabled on a default deployment.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/security/fundamentals/double-encryption" data-linktype="absolute-path">Double encryption</a></p>
<h4 id="dp-5-use-customer-managed-key-option-in-data-at-rest-encryption-when-required">3.5 - DP-5: Use customer-managed key option in data at rest encryption when required</h4>
<h4 id="features-13">Features</h4>
<h5 id="data-at-rest-encryption-using-cmk">Data at Rest Encryption Using CMK</h5>
<p><strong>Description</strong>: Data at-rest encryption using customer-managed keys is supported for customer content stored by the service. <a href="/en-us/azure/security/fundamentals/encryption-models" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="dp-6-use-a-secure-key-management-process">3.6 - DP-6: Use a secure key management process</h4>
<h4 id="features-14">Features</h4>
<h5 id="key-management-in-azure-key-vault">Key Management in Azure Key Vault</h5>
<p><strong>Description</strong>: The service supports Azure Key Vault integration for any customer keys, secrets, or certificates. <a href="/en-us/azure/key-vault/general/overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h4 id="dp-7-use-a-secure-certificate-management-process">3.7 - DP-7: Use a secure certificate management process</h4>
<h4 id="features-15">Features</h4>
<h5 id="certificate-management-in-azure-key-vault">Certificate Management in Azure Key Vault</h5>
<p><strong>Description</strong>: The service supports Azure Key Vault integration for any customer certificates. <a href="/en-us/azure/key-vault/certificates/certificate-scenarios" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>




<h3 id="logging-and-threat-detection">4. Logging and threat detection</h3>
<p><em>For more information, see the <a href="../mcsb-logging-threat-detection" data-linktype="relative-path">Microsoft cloud security benchmark: Logging and threat detection</a>.</em></p>
<h4 id="lt-1-enable-threat-detection-capabilities">4.1 - LT-1: Enable threat detection capabilities</h4>
<h4 id="features-17">Features</h4>
<h5 id="microsoft-defender-for-service--product-offering">Microsoft Defender for Service / Product Offering</h5>
<p><strong>Description</strong>: Service has an offering-specific Microsoft Defender solution to monitor and alert on security issues. <a href="/en-us/azure/security-center/azure-defender" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>

<h4 id="lt-4-enable-logging-for-security-investigation">4.2 - LT-4: Enable logging for security investigation</h4>
<h4 id="features-18">Features</h4>
<h5 id="azure-resource-logs">Azure Resource Logs</h5>
<p><strong>Description</strong>: Service produces resource logs that can provide enhanced service-specific metrics and logging. The customer can configure these resource logs and send them to their own data sink like a storage account or log analytics workspace. <a href="/en-us/azure/azure-monitor/platform/platform-logs-overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>True</td>
<td>True</td>
<td>Microsoft</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: No additional configurations are required as this is enabled on a default deployment.</p>
<p><strong>Reference</strong>: <a href="/en-us/azure/container-apps/log-options" data-linktype="absolute-path">Log storage and monitoring options in Azure Container Apps</a></p>


<h3 id="backup-and-recovery">5. Backup and recovery</h2>
<p><em>For more information, see the <a href="../mcsb-backup-recovery" data-linktype="relative-path">Microsoft cloud security benchmark: Backup and recovery</a>.</em></p>
<h4 id="br-1-ensure-regular-automated-backups">5.1 - BR-1: Ensure regular automated backups</h4>
<h4 id="features-21">Features</h4>
<h5 id="azure-backup">Azure Backup</h5>
<p><strong>Description</strong>: The service can be backed up by the Azure Backup service. <a href="/en-us/azure/backup/backup-overview" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h5 id="service-native-backup-capability">Service Native Backup Capability</h5>
<p><strong>Description</strong>: Service supports its own native backup capability (if not using Azure Backup). <a href="/en-us/security/benchmark/azure/security-controls-v3-backup-recovery#br-1-ensure-regular-automated-backups" data-linktype="absolute-path">Learn more</a>.</p>
<table>
<thead>
<tr>
<th>Supported</th>
<th>Enabled By Default</th>
<th>Configuration Responsibility</th>
</tr>
</thead>
<tbody>
<tr>
<td>False</td>
<td>Not Applicable</td>
<td>Not Applicable</td>
</tr>
</tbody>
</table>
<p><strong>Configuration Guidance</strong>: This feature is not supported to secure this service.</p>
<h2 id="reference">Reference</h2>
<ul>
<li>See the <a href="../overview" data-linktype="relative-path">Microsoft cloud security benchmark overview</a></li>
<li>Learn more about <a href="../security-baselines-overview" data-linktype="relative-path">Azure security baselines</a></li>
</ul>

-------

### Appendix A: Checklists
Pending Review.  I will add a link to the various Checklist. 
<!-- END of Landing Zone Accelerator - Azure Container Apps - Security.MD v1 -->

