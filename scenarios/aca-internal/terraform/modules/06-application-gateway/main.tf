resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
}

module "naming" {
  source       = "../../../../shared/terraform/modules/naming"
  uniqueId     = random_string.random.result
  environment  = var.environment
  workloadName = var.workloadName
  location     = var.location
}

resource "azurerm_user_assigned_identity" "appGatewayUserIdentity" {
  name = module.naming.resourceNames["applicationGatewayUserAssignedIdentity"]
  location = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
}

module "appGatewayAddCertificates" {
  source = "../../../../shared/terraform/modules/application-gateway/certificate-config"
}

module "appGatewayConfiguration" {
  source = "../../../../shared/terraform/modules/application-gateway/gateway-config"
}
