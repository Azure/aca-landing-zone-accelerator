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

module "frontDoor" {
  source                            = "../../../../shared/terraform/modules/frontdoor"
  privateLinkServiceName            = module.naming.resourceNames["privateLinkServiceName"]
  containerAppsManagedResourceGroup = local.containerAppsManagedResourceGroup
  resourceGroupName                 = var.resourceGroupName
  location                          = var.location
  privateLinkSubnetId               = var.privateLinkSubnetId
  frontDoorHostName                 = var.frontDoorOriginHostName
  frontDoorEndpointName             = var.frontDoorEndpointName
  frontDoorOriginGroupName          = var.frontDoorOriginGroupName
  frontDoorOriginName               = var.frontDoorOriginName
  frontDoorRouteName                = var.frontDoorOriginRouteName
  frontDoorProfileName              = module.naming.resourceNames["frontDoorProfile"]
}