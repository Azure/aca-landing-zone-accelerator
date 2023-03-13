# Networking considerations for Azure Container Apps

## Design Area Considerations

* The Container App Environment acts as a secure boundary around groups of container apps. This environment is connected to an Azure Virtual Network (VNet). You can choose to use an Azure managed VNet if this is a standalone environment without any additional network requirements, or you can use your own VNet. The latter offers two different connectivity models:
  * External: This type of deployment exposes the hosted container apps by using a virtual IP address that is accessible on the internet. 
  * Internal: This type of deployment exposes the hosted container apps on an IP address inside your virtual network. The internal endpoint is an internal load balancer. 
* A dedicated subnet is required for the Azure Container Apps Environment on the virtual network. The CIDR of the subnet should be /23 or larger.
* Azure Container Apps reserves 60 IPs in your VNet, and that number may grow as your container environment scales. Each revision of your app is assigned an IP address from the subnet. Outbound IPs aren't guaranteed and may change over time.
* Container Apps creates a managed public IP resource (even with the internal container apps environment), which is used for outbound and management traffic. 
* You can lock down a network via NSGs with more restrictive rules than the default NSG rules to control all inbound and outbound traffic for the Container App Environment.
* Azure Container Apps uses Envoy proxy as an edge HTTP proxy. HTTP requests are automatically redirected to HTTPs. Envoy terminates TLS after crossing its boundary. mTLS is only available when using Dapr. When you use the Dapr service invocation APIs, mTLS is enabled. However, because Envoy terminates mTLS, inbound calls from Envoy to Dapr-enabled container apps isn't encrypted.
* During the deployment of the Azure Container Apps Environmnent, many DNS lookups are performed. Some of these refer to Azure-internal domains. If you force DNS traffic through your custom DNS solution, you must configure your DNS server to forward unresolved DNS queries to [168.63.129.16](https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) (Azure DNS).
* Outbound (egress) network traffic CANNOT be sent through an Azure Firewall or network virtual appliance cluster. Use of User Defined Routes is currently not supported.
* If you aim to run your solution on multiple Azure Container Apps Environments for resiliency or proximity reasons, a global load-balancing service such as Azure Traffic Manager or Azure Front Door can be used to route traffic across environments or regions.
  

## Design Area Recommendations
  
* Deploy container apps in your own custom virtual network to have more control over the network configuration.
* When publishing internet-facing services, use a service such as Azure Application Gateway to secure inbound connectivity.
* When using a load-balancing or security service such as Azure Application Gateway or Azure Front Door, use an internal network configuration so that traffic from the load-balancer to the Azure Container Apps Environment uses an internal connection. 
* Enable ingress to expose your application over HTTPs or TCP port.
* Secure your network by using Network Security Groups (NSG) and blocking inbound and outbound traffic other than is required.
* Use Azure DDoS Protection Standard to protect the virtual network used for the Azure Container Apps Environment.
* Use Private Link to secure network connections and use private IP-based connectivity to other managed Azure services used that support Private Link, such as Azure Storage, Azure Container Registry, Azure SQL Database, and Azure Key Vault.
* All endpoints for the solution (internal and external) should only accept TLS encrypted connections (HTTPS).
* For internet-facing and security-critical, internal-facing web applications, use a web application firewall with the ingress controller. Azure Application Gateway and Azure Front Door both integrate the Azure Web Application Firewall to protect web-based applications.
   
## References

- [Networking architecture in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/networking)
- [Securing a custom VNET in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration)
- [Network proxying in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/network-proxy)
  
