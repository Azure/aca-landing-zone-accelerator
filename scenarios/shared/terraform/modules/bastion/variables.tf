variable "vnetName" {
  type = string
}

variable "vnetResourceGroupName" {
  type = string
}

variable "bastionNsgName" {
  type = string
}

variable "securityRules" {
  default = [{
    "name"                     = "AllowHttpsInbound"
    "description"              = "AllowHttpsInbound"
    "priority"                 = 120
    "protocol"                 = "Tcp"
    "destinationPortRanges"    = ["443"]
    "access"                   = "Allow"
    "direction"                = "Inbound"
    "sourcePortRange"          = "*"
    "sourceAddressPrefix"      = "Internet"
    "destinationAddressPrefix" = "*"
    },
    {
      "name"                     = "AllowGatewayManagerInbound"
      "description"              = "AllowGatewayManagerInbound"
      "priority"                 = 130
      "protocol"                 = "Tcp"
      "destinationPortRanges"    = ["443"]
      "access"                   = "Allow"
      "direction"                = "Inbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "GatewayManager"
      "destinationAddressPrefix" = "*"
    },
    {
      "name"                     = "AllowAzureLoadBalancerInbound"
      "description"              = "AllowAzureLoadBalancerInbound"
      "priority"                 = 140
      "protocol"                 = "Tcp"
      "destinationPortRanges"    = ["443"]
      "access"                   = "Allow"
      "direction"                = "Inbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "AzureLoadBalancer"
      "destinationAddressPrefix" = "*"
    },
    {
      "name"                     = "AllowBastionHostCommunicationInbound"
      "description"              = "AllowBastionHostCommunicationInbound"
      "priority"                 = 150
      "protocol"                 = "*"
      "destinationPortRanges"    = ["8080", "5701"]
      "access"                   = "Allow"
      "direction"                = "Inbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "VirtualNetwork"
      "destinationAddressPrefix" = "VirtualNetwork"
    },
    {
      "name"                     = "AllowSshRdpOutbound"
      "description"              = "AllowSshRdpOutbound"
      "priority"                 = 100
      "protocol"                 = "*"
      "destinationPortRanges"    = ["22", "3389"]
      "access"                   = "Allow"
      "direction"                = "Outbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "*"
      "destinationAddressPrefix" = "VirtualNetwork"
    },
    {
      "name"                     = "AllowAzureCloudOutbound"
      "description"              = "AllowAzureCloudOutbound"
      "priority"                 = 110
      "protocol"                 = "Tcp"
      "destinationPortRanges"    = ["443"]
      "access"                   = "Allow"
      "direction"                = "Outbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "*"
      "destinationAddressPrefix" = "AzureCloud"
    },
    {
      "name"                     = "AllowBastionCommunication"
      "description"              = "AllowBastionCommunication"
      "priority"                 = 120
      "protocol"                 = "*"
      "destinationPortRanges"    = ["8080", "5701"]
      "access"                   = "Allow"
      "direction"                = "Outbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "VirtualNetwork"
      "destinationAddressPrefix" = "VirtualNetwork"
    },
    {
      "name"                     = "AllowGetSessionInformation"
      "description"              = "AllowGetSessionInformation"
      "priority"                 = 130
      "protocol"                 = "*"
      "destinationPortRanges"    = ["80"]
      "access"                   = "Allow"
      "direction"                = "Outbound"
      "sourcePortRange"          = "*"
      "sourceAddressPrefix"      = "*"
      "destinationAddressPrefix" = "Internet"
  }]
}

variable "addressPrefixes" {}

variable "bastionPipName" {}

variable "tags" {}

variable "bastionHostName" {}

variable "location" {}