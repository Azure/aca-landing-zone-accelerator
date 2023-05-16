variable "keyVaultName" {}

variable "appGatewayUserAssignedIdentityPrincipalId" {}

variable "appGatewayCertificateKeyName" {}

variable "appGatewayCertificateData" {
  default = "configuration/acahello.demoapp.com.pfx"
}

variable "resourceGroupName" {}
