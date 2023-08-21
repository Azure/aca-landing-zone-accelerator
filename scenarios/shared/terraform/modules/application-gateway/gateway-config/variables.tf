variable "appGatewayPublicIpName" {}

variable "location" {}

variable "resourceGroupName" {}

variable "tags" {}

variable "appGatewayName" {}

variable "appGatewayUserAssignedIdentityId" {}

variable "appGatewaySubnetId" {}

variable "appGatewayPrimaryBackendEndFQDN" {}

variable "appGatewayFQDN" {

}

variable "keyVaultSecretId" {
  sensitive = true
}