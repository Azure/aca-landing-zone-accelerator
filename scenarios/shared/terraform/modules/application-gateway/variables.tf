variable "appGatewayPublicIpName" {}

variable "location" {}

variable "resourceGroupName" {}

variable "tags" {}

variable "appGatewayName" {}

variable "appGatewayUserAssignedIdentityId" {}

variable "appGatewaySubnetId" {}

variable "appGatewayPrimaryBackendEndFQDN" {}

variable "appGatewayLogAnalyticsId" {}

variable "appGatewayFQDN" {

}

variable "keyVaultSecretId" {
  sensitive = true
}

variable "diagnosticSettingName" {

}

variable "skuName" {
  default = "WAF_Medium"
  validation {
    condition = var.skuName == "Standard_Small" || var.skuName == "Standard_Medium" || var.skuName == "Standard_Large" || var.skuName == "WAF_Medium" || var.skuName == "WAF_Large" || var.skuName == "Standard_v2" || var.skuName == "WAF_v2"
    error_message = "The sku value needs to be one of the following: Standard_Small, Standard_Medium, Standard_Large, WAF_Medium, WAF_Large, Standard_v2, WAF_v2"
  }
}

variable "skuTier" {
  default = "WAF"
  validation {
    condition = var.skuTier == "WAF" || var.skuTier == "Standard" || var.skuTier == "Standard_v2" || var.skuTier == "WAF_v2"
    error_message = "The sku tier needs to be one of the following: WAF, Standard, Standard_v2, WAF_v2"
  }
}

variable "capacity" {
  default = 1
  validation {
    condition = var.capacity >= 1 && var.capacity <= 10
    error_message = "The capacity needs to be between 1 and 10"
  }
}

variable "sslPolicyCipherSuites" {
  default = ["TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"]
  validation {
    condition = length(var.sslPolicyCipherSuites) > 0
    error_message = "The sslPolicyCipherSuites needs to be a list of cipher suites"
  }
}

variable "sslProtocolEnums" {
  default = "TLSv1_2"
  validation {
    condition = var.sslProtocolEnums == "TLSv1_0" || var.sslProtocolEnums == "TLSv1_1" || var.sslProtocolEnums == "TLSv1_2" || var.sslProtocolEnums == "TLSv1_3"
    error_message = "SSL protocol must be one of the following: TLSv1_0, TLSv1_1, TLSv1_2, TLSv1_3"
  }
}

variable "sslPolicyName" {
  default = null
  validation {
    condition = var.sslPolicyName == "AppGwSslPolicy20150501" || var.sslPolicyName == "AppGwSslPolicy20170401" || var.sslPolicyName == "AppGwSslPolicy20170401S" || var.sslPolicyName == "AppGwSslPolicy20220101" || var.sslPolicyName == "AppGwSslPolicy20220101S"
    error_message = "The SSL policy must be one of the following: AppGwSslPolicy20150501, AppGwSslPolicy20170401, AppGwSslPolicy20170401S, AppGwSslPolicy20220101, AppGwSslPolicy20220101S"
  }
}

variable "sslPolicyType" {
  default = "Custom"
  validation {
    condition = var.sslPolicyType == "Custom" || var.sslPolicyType == "Predefined" || var.sslPolicyType == "CustomV2"
    error_message = "The SSL policy must be one of the following: Custom, Predefined, CustomV2"
  }
}

variable "autoscaleMaxCapacity" {
  default = -1
}

variable "autoscaleMinCapacity" {
  default = -1
}

variable "autoScaleSettings" {
  default = []
}
variable "makeZoneRedundant" {
  default = true
}

variable "ddosProtectionEnabled" {
  default = "Disabled"
  validation {
    condition = var.ddosProtectionEnabled == "Enabled" || var.ddosProtectionEnabled == "Disabled" || var.ddosProtectionEnabled == "VirtualNetworkInherited"
    error_message = "The DDOS protection must be set to Enabled, Disabled or VirtualNetworkInherited"
  }
}

variable "gatewayIPConfigurations" {
  default = []
}

variable "frontendPorts" {
  default = []
}

variable "frontendIPConfigurations" {
  default = []
}

variable "backendAddressPools" {
  default = []
}

variable "sslCertificates" {
  default = []
}

variable "backendHttpSettings" {
  default = []
}

variable "httpListeners" {
  default = []
}

variable "requestRoutingRules" {
  default = []
}

variable "probes" {
  default = []
}

variable "zones" {
  default = []
}

variable "firewallConfiguration" {
  default = []
}