variable "location" {
  type = string
}

variable "tags" {
  default = {}
}

variable "hubResourceGroupName" {}

variable "firewallName" {
  type = string
}

variable "publicIpFirewallName" {
  type = string
}

variable "publicIpFirewallManagementName" {
  type = string
}

variable "subnetFirewallId" {
  type = string
}

variable "subnetFirewallManagementId" {
  type = string
}

variable "firewallPolicyName" {
  type = string
}

variable "firewallSkuName" {
  type = string
  default = "AZFW_VNet" # "AZFW_Hub"
}

variable "firewallSkuTier" {
  type = string
  default = "Basic" # "Standard" "Premium" "Basic"
}

variable "firewallAvailabilityZones" {
  type    = list(number)
  default = [1] # [1, 2, 3]
}

variable "firewallPolicyRuleCollectionGroups" {
  description = "Firewall policy rule collection group configuration"
  type = list(object({
    name     = string
    priority = number

    application_rule_collections = list(object({
      name     = string,
      priority = number,
      action   = string,
      rules = list(object({
        name                  = string,
        source_addresses      = list(string),
        source_ip_groups      = list(string),
        destination_fqdns     = list(string),
        destination_addresses = list(string),
        protocols = list(object({
          port = string,
          type = string
        }))
      }))
    }))

    network_rule_collections = list(object({
      name     = string,
      priority = number,
      action   = string,
      rules = list(object({
        name                  = string,
        source_addresses      = list(string),
        source_ip_groups      = list(string),
        destination_ports     = list(string),
        destination_addresses = list(string),
        destination_ip_groups = list(string),
        destination_fqdns     = list(string),
        protocols             = list(string)
      }))
    }))

    nat_rule_collections = list(object({
      name     = string,
      priority = number,
      action   = string,
      rules = list(object({
        name                = string,
        source_addresses    = list(string),
        destination_address = string,
        destination_ports   = list(string),
        translated_port     = number,
        translated_address  = string,
        protocols           = list(string)
      }))
    }))
    }
    )
  )
}
