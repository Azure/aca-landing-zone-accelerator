variable "subscription_id" {
  sensitive = true
  type = string
}

variable "workloadName" {
  type = string
  validation {
    condition     = length(var.workloadName) >= 2 && length(var.workloadName) <= 10
    error_message = "Name must be greater at least 2 characters and not greater than 10."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = length(var.environment) <= 8
    error_message = "Environment name can't be greater than 8 characters long."
  }
}

variable "location" {
  type    = string
}

variable "hubVnetId" {
  default = ""
}

variable "spokeResourceGroupName" {
  default = ""

}

variable "tags" {}

variable "vnetAddressPrefixes" {
  default = ""

}

variable "infraSubnetAddressPrefix" {
  default = ""

}

variable "infraSubnetName" {
  default = "snet-infra"

}

variable "privateEndpointsSubnetName" {
  default = "snet-pep"
}

variable "privateEndpointsSubnetAddressPrefix" {
  default = ""

}

variable "applicationGatewaySubnetName" {
  default = "snet-agw"
}

variable "applicationGatewaySubnetAddressPrefix" {
  default = ""
}

variable "jumpboxSubnetName" {
  default = "snet-jumpbox"
}

variable "jumpboxSubnetAddressPrefix" {
  default = ""
}

variable "vmSize" {}

variable "vmAdminUsername" {
  default = "vmadmin"
}

variable "vmAdminPassword" {
  sensitive = true
}

variable "vmLinuxSshAuthorizedKeys" {}

variable "vmJumpboxOSType" {
  default = "Linux"
  validation {
    condition = anytrue([
      var.vmJumpboxOSType == "Linux",
      var.vmJumpboxOSType == "Windows",
      var.vmJumpboxOSType == "none",
    ])
    error_message = "OS Type must be Linux, Windows or none."
  }
}

variable "vmLinuxAuthenticationType" {
  type = string
  default = "password"
  validation {
    condition = anytrue([
      var.vmLinuxAuthenticationType == "password",
      var.vmLinuxAuthenticationType == "sshPublicKey"
    ])
    error_message = "Authentication type must be password or sshPublicKey."
  }
}

variable "vmSubnetName" {
  default = "snet-jumpbox"
  type    = string
}

variable "containerAppsSecurityRules" {
  default = [
    {
      "name" : "Allow_Internal_AKS_Connection_Between_Nodes_And_Control_Plane_UDP",
      "description" : "internal AKS secure connection between underlying nodes and control plane..",
      "protocol" : "Udp",
      "sourceAddressPrefix" : "VirtualNetwork",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "AzureCloud.eastus",
      "destinationPortRanges" : ["1194"],
      "access" : "Allow",
      "priority" : 100,
      "direction" : "Outbound"
    },
    {
      "name" : "Allow_Internal_AKS_Connection_Between_Nodes_And_Control_Plane_TCP",
      "description" : "internal AKS secure connection between underlying nodes and control plane..",
      "protocol" : "Tcp",
      "sourceAddressPrefix" : "VirtualNetwork",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "AzureCloud.eastus",
      "destinationPortRanges" : ["9000"],
      "access" : "Allow",
      "priority" : 110,
      "direction" : "Outbound"
    },
    {
      "name" : "Allow_Azure_Monitor",
      "description" : "Allows outbound calls to Azure Monitor.",
      "protocol" : "Tcp",
      "sourceAddressPrefix" : "VirtualNetwork",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "AzureCloud.eastus",
      "destinationPortRanges" : ["443"],
      "access" : "Allow",
      "priority" : 120,
      "direction" : "Outbound"
    },
    {
      "name" : "Allow_Outbound_443",
      "description" : "Allowing all outbound on port 443 provides a way to allow all FQDN based outbound dependencies that don't have a static IP",
      "protocol" : "Tcp",
      "sourceAddressPrefix" : "VirtualNetwork",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["443"],
      "access" : "Allow",
      "priority" : 130,
      "direction" : "Outbound"
    },
    {
      "name" : "Allow_NTP_Server",
      "description" : "NTP server",
      "protocol" : "Udp",
      "sourceAddressPrefix" : "VirtualNetwork",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["123"],
      "access" : "Allow",
      "priority" : 140,
      "direction" : "Outbound"
    },
    {
      "name" : "Allow_Container_Apps_control_plane",
      "description" : "Container Apps control plane",
      "protocol" : "Tcp",
      "sourceAddressPrefix" : "VirtualNetwork",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["5671", "5672"],
      "access" : "Allow",
      "priority" : 150,
      "direction" : "Outbound"
    }
  ]
}

variable "appGatewaySecurityRules" {
  default = [
    {
      "name" : "HealthProbes",
      "description" : "Allow HealthProbes from gateway Manager.",
      "protocol" : "*",
      "sourceAddressPrefix" : "GatewayManager",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["65200-65535"],
      "access" : "Allow",
      "priority" : 100,
      "direction" : "Inbound"
    },
    {
      "name" : "Allow_TLS",
      "description" : "allow https incoming connections",
      "protocol" : "*",
      "sourceAddressPrefix" : "*",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["443"],
      "access" : "Allow",
      "priority" : 110,
      "direction" : "Inbound"
    },
    {
      "name" : "Allow_HTTP",
      "description" : "allow http incoming connections",
      "protocol" : "*",
      "sourceAddressPrefix" : "*",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["80"],
      "access" : "Allow",
      "priority" : 120,
      "direction" : "Inbound"
    },
    {
      "name" : "Allow_AzureLoadBalancer",
      "description" : "allow AzureLoadBalancer incoming connections",
      "protocol" : "*",
      "sourceAddressPrefix" : "AzureLoadBalancer",
      "sourcePortRange" : "*",
      "destinationAddressPrefix" : "*",
      "destinationPortRanges" : ["80"],
      "access" : "Allow",
      "priority" : 130,
      "direction" : "Inbound"
    }
  ]
}

variable "firewallPrivateIp" {
  type = string
}
