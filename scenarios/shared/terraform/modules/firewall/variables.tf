variable "location" {
    type    = string
}

variable "tags" {
    type    = map(string)
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