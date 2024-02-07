targetScope = 'resourceGroup'
// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string

@description('The name of the azure firewall to create.')
param firewallName string

@description('The name for the public ip address of the azure firewall.')
param publicIpName string

@description('The Name of the virtual network in which afw is created.')
param afwVNetName string

@description('The log analytics workspace id to which the azure firewall will send logs.')
param logAnalyticsWorkspaceId string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('CIDR of the spoke infrastructure subnet.')
param spokeInfraSubnetAddressPrefix string

param azureFirewallSubnetManagementAddressPrefix string

var applicationRuleCollections = [
  {
    name: 'ace-allow-rules'
    properties: {
      action: {
        type: 'allow'
      }
      priority: 110
      rules: [
        {
          name: 'ace-general-allow-rules'
          protocols: [
            {
              port: '80'
              protocolType: 'HTTP'
            }
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          targetFqdns: [
            'mcr.microsoft.com'
            '*.data.mcr.microsoft.com'
            '*.blob.${environment().suffixes.storage}' //NOTE: If you use ACR the endpoint must be added as well.
          ]
        }
        {
          name: 'ace-acr-and-docker-allow-rules'
          protocols: [
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          targetFqdns: [
            '*.blob.${environment().suffixes.storage}'
            'login.microsoft.com'
            '*.azurecr.io' //NOTE: for less permisive environment replace wildcard with actual(s) Container Registries
            'hub.docker.com'
            'registry-1.docker.io'
            'production.cloudflare.docker.com'
          ]
        }
        {
          name: 'ace-managed-identity-allow-rules'
          protocols: [
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          targetFqdns: [
            '*.identity.azure.net'
            'login.microsoftonline.com'
            '*.login.microsoftonline.com'
            '*.login.microsoft.com'
          ]
        }
        {
          name: 'ace-keyvault-allow-rules'
          protocols: [
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          targetFqdns: [
            '*${environment().suffixes.keyvaultDns}' //NOTE: for less permisive environment replace wildcard with actual(s) KeyVault
            #disable-next-line no-hardcoded-env-urls
            'login.microsoft.com'
          ]
        }
      ]
    }
  }
  {
    name: 'allow_azure_monitor'
    properties: {
      action: {
        type: 'allow'
      }
      priority: 120
      rules: [
        {
          fqdnTags: []
          targetFqdns: [
            'dc.applicationinsights.azure.com'
            'dc.applicationinsights.microsoft.com'
            'dc.services.visualstudio.com'
            '*.in.applicationinsights.azure.com'
            'live.applicationinsights.azure.com'
            'rt.applicationinsights.microsoft.com'
            'rt.services.visualstudio.com'
            '*.livediagnostics.monitor.azure.com'
            '*.monitoring.azure.com'
            'agent.azureserviceprofiler.net'
            '*.agent.azureserviceprofiler.net'
            '*.monitor.azure.com'
          ]
          name: 'allow-azure-monitor'
          protocols: [
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
        }
      ]
    }
  }
  {
    name: 'allow_core_dev_fqdn' //NOTE: This rule is optional, and used here only to demonstrate that there are possibly more fqdns that need to be allowed, depending on your scenario
    properties: {
      action: {
        type: 'allow'
      }
      priority: 130
      rules: [
        {
          name: 'allow-developer-services'
          fqdnTags: []
          targetFqdns: [
            'github.com'
            '*.github.com'
            'ghcr.io'
            '*.ghcr.io'
            '*.nuget.org'
            '*.blob.${environment().suffixes.storage}' // might replace wildcard with specific FQDN
            '*.table.${environment().suffixes.storage}' // might replace wildcard with specific FQDN
            '*.servicebus.windows.net' // might replace wildcard with specific FQDN
            'githubusercontent.com'
            '*.githubusercontent.com'
            'dev.azure.com'
            'portal.azure.com'
            '*.portal.azure.com'
            '*.portal.azure.net'
            'appservice.azureedge.net'
            '*.azurewebsites.net'
          ]
          protocols: [
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
        }
        {
          name: 'allow-certificate-dependencies'
          fqdnTags: []
          targetFqdns: [
            '*.delivery.mp.microsoft.com'
            'ctldl.windowsupdate.com'
            'ocsp.msocsp.com'
            'oneocsp.microsoft.com'
            'crl.microsoft.com'
            'www.microsoft.com'
            '*.digicert.com'
            '*.symantec.com'
            '*.symcb.com'
            '*.d-trust.net'
          ]
          protocols: [
            {
              port: '80'
              protocolType: 'HTTP'
            }
            {
              port: '443'
              protocolType: 'HTTPS'
            }
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
        }
      ]
    }
  }
]

var networkRules = [
  {
    name: 'ace-allow-rules'
    properties: {
      action: {
        type: 'allow'
      }
      priority: 100
      // For more  Azure resources (than KeyVault, ACR etc which we use here) you are using with Azure Firewall, 
      // please refer to the service tags documentation: https://learn.microsoft.com/azure/virtual-network/service-tags-overview#available-service-tags
      rules: [
        {
          name: 'ace-general-allow-rule'
          protocols: [
            'Any'
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          destinationAddresses: [
            'MicrosoftContainerRegistry' //For even less permisive environment, you can point to a specific MCR region, i.e. 'MicrosoftContainerRegistry.Westeurope'
            'AzureFrontDoor.FirstParty'
          ]
          destinationPorts: [
            '443'
          ]
        }
        {
          name: 'ace-acr-allow-rule'
          protocols: [
            'Any'
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          destinationAddresses: [
            'AzureContainerRegistry' //For even less permisive environment, you can point to a specific ACR region, i.e. 'MicrosoftContainerRegistry.Westeurope'
            'AzureActiveDirectory'
          ]
          destinationPorts: [
            '443'
          ]
        }
        {
          name: 'ace-keyvault-allow-rule'
          protocols: [
            'Any'
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          destinationAddresses: [
            'AzureKeyVault' //For even less permisive environment, you can point to a specific keyvault region, i.e. 'MicrosoftContainerRegistry.Westeurope'
            'AzureActiveDirectory'
          ]
          destinationPorts: [
            '443'
          ]
        }
        {
          name: 'ace-managedIdentity-allow-rule'
          protocols: [
            'Any'
          ]
          sourceAddresses: [
            spokeInfraSubnetAddressPrefix
          ]
          destinationAddresses: [
            'AzureActiveDirectory'
          ]
          destinationPorts: [
            '443'
          ]
        }
      ]
    }
  }
]

resource hubVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: afwVNetName
}

resource fwManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: hubVnet
  name: 'AzureFirewallManagementSubnet'
  //name: '${hubVnet.name}/AzureFirewallManagementSubnet'
  properties: {
    addressPrefix: azureFirewallSubnetManagementAddressPrefix
  }
}

@description('The azure firewall deployment.')
module afw '../../../../../shared/bicep/azureFirewalls/main.bicep' = {
  name: 'afw-deployment'
  params: {
    tags: tags
    location: location
    name: firewallName
    publicIpName: publicIpName
    azureSkuTier: 'Basic'
    vNetId: hubVnet.id
    additionalPublicIpConfigurations: []
    applicationRuleCollections: applicationRuleCollections
    networkRuleCollections: networkRules
    natRuleCollections: []
    threatIntelMode: 'Deny'
    diagnosticWorkspaceId: logAnalyticsWorkspaceId
    azFwManagementSubnetId: fwManagementSubnet.id
  }
}

output afwPrivateIp string = afw.outputs.privateIp
output afwId string = afw.outputs.resourceId
