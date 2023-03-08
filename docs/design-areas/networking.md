# Networking considerations for Azure Container Apps

## Design Area Considerations

* Container App Environment, which acts as a secure boundary around groups of container apps, are deployed in a VNet. You can bring your custom VNet. There are two deployment methods when you bring your own VNet.
  * External: This type of deployment exposes the hosted container apps by using a virtual IP address that is accessible on the internet. 
  * Internal: This type of deployment exposes the hosted container apps on an IP address inside your virtual network. The internal endpoint is an internal load balancer. 
* A dedicated subnet is required for Container Apps Environment if you use custom virtual network. CIDR of the subnet should be /23 or larger.
* Container Apps reserves 60 IPs in your VNET, and the amount may grow as your container environment scales. Each revision of your app is assigned an IP address from the subnet.  Outbound IPs aren't guaranteed and may change over time.
* Container Apps creates a managed public IP resource (even with the internal container apps environment), which is used for outbound and management traffic. 
* You can lock down a network via NSGs with more restrictive rules than the default NSG rules to control all inbound and outbound traffic for the Container App Environment.
* Azure Container Apps uses Envoy proxy as an edge HTTP proxy. HTTP requests are automatically redirected to HTTPs. Envoy terminates TLS after crossing its boundary. mTLS is only available when using Dapr. When you use Dapr service invocation APIs, mTLS is enabled. However, because Envoy terminates mTLS, inbound calls from Envoy to Dapr-enabled container apps isn't encrypted.
* If your VNET uses a custom DNS server instead of the default Azure-provided DNS server, configure your DNS server to forward unresolved DNS queries to 168.63.129.16. You must use Azure recursive resolvers.
* Outbound (egress) network traffic CANNOT be sent through an Azure Firewall or network virtual appliance cluster. UDR is currently not supported.
* Global load-balancing mechanisms such as Azure Traffic Manager and Azure Front Door increase resiliency by routing traffic across apps in multiple container app environments, potentially in different Azure regions.
  

## Design Area Recommendations
  
* Deploy container apps in your own custom virtual network to have better control over the network.
* Deploy container app environment as internal, if you don't need your apps to be exposed publically directly.
* Enable ingress to expose your application over HTTPs or TCP port.
* Secure your network by using NSGs with more restrictive rules than the default NSG rules to control all inbound and outbound traffic for the Container App Environment.
* Use Azure DDoS Protection Standard to protect the virtual network used for the AKS cluster.
* Use Private Link to secure network connections and use private IP-based connectivity to other managed Azure services used that support Private Link, such as Azure Storage, Azure Container Registry, Azure SQL Database, and Azure Key Vault.
* All web applications configured to use an ingress should use TLS encryption and not allow access over unencrypted HTTP.
* For internet-facing and security-critical, internal-facing web applications, use a web application firewall with the ingress controller. Azure Application Gateway and Azure Front Door both integrate the Azure Web Application Firewall to protect web-based applications.
   
## References

- [Networking architecture in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/networking)
- [Securing a custom VNET in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration)
- [Network proxying in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/network-proxy)
  
