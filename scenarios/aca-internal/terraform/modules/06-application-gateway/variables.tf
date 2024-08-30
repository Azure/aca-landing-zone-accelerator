variable "subscription_id" {
  sensitive = true
  type = string
}

variable "appGatewayCertificateKeyName" {}

variable "location" {}

variable "resourceGroupName" {}

variable "environment" {}

variable "workloadName" {}

variable "appGatewayFQDN" {}

variable "appGatewayPrimaryBackendEndFQDN" {}

variable "appGatewaySubnetId" {}

variable "appGatewayLogAnalyticsId" {}

variable "tags" {}

variable "keyVaultName" {}

variable "appGatewayCertificatePath" {}

variable "logAnalyticsWorkspaceId" {}
variable "ddosProtectionEnabled" {
  default = "Enabled"
}

variable "enableAppGatewayCertificate" {
  default = true
}

variable "makeZoneRedundant" {
  default = true
}
