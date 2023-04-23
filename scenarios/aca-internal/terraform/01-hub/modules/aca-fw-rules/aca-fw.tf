# Firewall Policy

resource "azurerm_firewall_policy" "aca" {
  name                = "acapolicy"
  resource_group_name = var.resource_group_name
  location            = var.location
}

output "fw_policy_id" {
  value = azurerm_firewall_policy.aca.id
}

# Rules Collection Group

resource "azurerm_firewall_policy_rule_collection_group" "aca" {
  name               = "aca-rcg"
  firewall_policy_id = azurerm_firewall_policy.aca.id
  priority           = 200

  # application_rule_collection {
  #   name     = "aca_app_rules"
  #   priority = 205
  #   action   = "Allow"
  #   rule {
  #     name = "aca_service"
  #     protocols {
  #       type = "Https"
  #       port = 443
  #     }
  #     source_addresses      = ["10.1.0.0/16"]
  #     destination_fqdn_tags = ["AzureKubnernetesService"]
  #   }
  # }

  network_rule_collection {
    name     = "aca_network_rules"
    priority = 201
    action   = "Allow"
    rule {
      name                  = "https"
      protocols             = ["TCP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "dns"
      protocols             = ["UDP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "time"
      protocols             = ["UDP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
    rule {
      name                  = "tunnel_udp"
      protocols             = ["UDP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["1194"]
    }
    rule {
      name                  = "tunnel_tcp"
      protocols             = ["TCP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["9000"]
    }
  }
}

variable "resource_group_name" {}

variable "location" {}