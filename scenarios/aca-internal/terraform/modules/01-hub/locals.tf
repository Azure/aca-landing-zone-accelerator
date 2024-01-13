locals {
  firewallPolicyRuleCollectionGroups = [
    {
      name     = "policy-rules-collection"
      priority = "1000"

      application_rule_collections = [
        {
          name     = "ace-general-allow-rules"
          priority = 110
          action   = "Allow"
          rules = [
            {
              name                  = "ace-general-allow-rules"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["mcr.microsoft.com", "*.data.mcr.microsoft.com", "*.blob.core.windows.net"] //NOTE: If you use ACR the endpoint must be added as well.
              protocols             = [{ port = "80", type = "Http" }, { port = "443", type = "Https" }]
              destination_addresses = []
            },
            {
              name                  = "ace-acr-and-docker-allow-rules"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["*.blob.core.windows.net", "login.microsoft.com", "*.azurecr.io", "hub.docker.com", "registry-1.docker.io", "production.cloudflare.docker.com", "index.docker.io", "auth.docker.io"]
              protocols             = [{ port = "443", type = "Https" }]
              destination_addresses = []
            },
            {
              name                  = "ace-managed-identity-allow-rules"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["*.identity.azure.net", "login.microsoftonline.com", "*.login.microsoftonline.com", "*.login.microsoft.com"]
              protocols             = [{ port = "443", type = "Https" }]
              destination_addresses = []
            },
            {
              name                  = "ace-keyvault-allow-rules"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["*.vault.azure.net", "login.microsoft.com"]
              protocols             = [{ port = "443", type = "Https" }]
              destination_addresses = []
            }
          ]
        },
        {
          name     = "allow-azure-monitor"
          priority = 120
          action   = "Allow"

          rules = [
            {
              name                  = "allow-azure-monitor"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["dc.applicationinsights.azure.com", "dc.applicationinsights.microsoft.com", "dc.services.visualstudio.com", "*.in.applicationinsights.azure.com", "live.applicationinsights.azure.com", "rt.applicationinsights.microsoft.com", "rt.services.visualstudio.com", "*.livediagnostics.monitor.azure.com", "*.monitoring.azure.com", "agent.azureserviceprofiler.net", "*.agent.azureserviceprofiler.net", "*.monitor.azure.com"]
              protocols             = [{ port = "443", type = "Https" }]
              destination_addresses = []
            }
          ]
        },
        {
          name     = "allow-core-dev-fqdn"
          priority = 130
          action   = "Allow"

          rules = [
            {
              name                  = "allow-developer-services"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["github.com", "*.github.com", "ghcr.io", "*.ghcr.io", "*.nuget.org", "*.blob.core.windows.net", "*.table.core.windows.net", "*.servicebus.windows.net", "githubusercontent.com", "*.githubusercontent.com", "dev.azure.com", "portal.azure.com", "*.portal.azure.com", "*.portal.azure.net", "appservice.azureedge.net", "*.azurewebsites.net"]
              protocols             = [{ port = "443", type = "Https" }]
              destination_addresses = []
            },
            {
              name                  = "allow-certificate-dependencies"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_fqdns     = ["*.delivery.mp.microsoft.com", "ctldl.windowsupdate.com", "ocsp.msocsp.com", "oneocsp.microsoft.com", "crl.microsoft.com", "www.microsoft.com", "*.digicert.com", "*.symantec.com", "*.symcb.com", "*.d-trust.net"]
              protocols             = [{ port = "80", type = "Http" }, { port = "443", type = "Https" }]
              destination_addresses = []
            }
          ]
        }
      ]

      network_rule_collections = [
        {
          name     = "ace-allow-rules"
          priority = 100
          action   = "Allow"

          rules = [
            {
              name                  = "ace-general-allow-rule"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_ports     = ["443"]
              destination_addresses = ["MicrosoftContainerRegistry", "AzureFrontDoor.FirstParty"]
              destination_ip_groups = []
              destination_fqdns     = []
              protocols             = ["Any"]
            },
            {
              name                  = "ace-acr-allow-rule"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_ports     = ["443"]
              destination_addresses = ["AzureContainerRegistry", "AzureActiveDirectory"]
              destination_ip_groups = []
              destination_fqdns     = []
              protocols             = ["Any"]
            },
            {
              name                  = "ace-keyvault-allow-rule"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_ports     = ["443"]
              destination_addresses = ["AzureKeyVault", "AzureActiveDirectory"]
              destination_ip_groups = []
              destination_fqdns     = []
              protocols             = ["Any"]
            },
            {
              name                  = "ace-managedIdentity-allow-rule"
              source_addresses      = ["${var.infraSubnetAddressPrefix}"]
              source_ip_groups      = []
              destination_ports     = ["443"]
              destination_addresses = ["AzureActiveDirectory"]
              destination_ip_groups = []
              destination_fqdns     = []
              protocols             = ["Any"]
            }
          ]
        }
      ]

      nat_rule_collections = []
    }
  ]
}
