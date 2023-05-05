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

resource "azurerm_resource_group" "spokeResourceGroup" {
  name     = var.spokeResourceGroupName != "" ? var.spokeResourceGroupName : module.naming.resourceNames["rgSpokeName"]
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source            = "../../../../shared/terraform/modules/networking/vnet"
  networkName       = module.naming.resourceNames["vnetSpoke"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  addressSpace      = var.vnetAddressPrefixes
  tags              = var.tags
  subnets           = local.subnets
}

module "nsgContainerAppsEnvironmentNsg" {
  source            = "../../../../shared/terraform/modules/networking/nsg"
  nsgName           = module.naming.resourceNames["containerAppsEnvironmentNsg"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  securityRules     = var.securityRules
  tags              = var.tags
}

resource "azurerm_subnet_network_security_group_association" "securityGroupAssociation" {
  subnet_id                 = data.azurerm_subnet.infraSubnet.id
  network_security_group_id = module.nsgContainerAppsEnvironmentNsg.nsgId
}

module "peeringSpokeToHub" {
  source         = "../../../../shared/terraform/modules/networking/peering"
  localVnetName  = module.vnet.vnetName
  remoteVnetId   = var.hubVnetId
  remoteVnetName = local.hubVnetName
  remoteRgName   = azurerm_resource_group.spokeResourceGroup.name
}

module "peeringHubToSpoke" {
  source         = "../../../../shared/terraform/modules/networking/peering"
  localVnetName  = local.hubVnetName
  remoteVnetId   = module.vnet.vnetId
  remoteVnetName = local.hubVnetName
  remoteRgName   = local.hubVnetResourceGroup
}

data "azurerm_subnet" "infraSubnet" {
  depends_on = [
    module.vnet
  ]
  name                 = var.infraSubnetName
  resource_group_name  = azurerm_resource_group.spokeResourceGroup.name
  virtual_network_name = module.vnet.vnetName
}

data "azurerm_subnet" "privateEndpointsSubnet" {
  depends_on = [
    module.vnet
  ]
  name                 = var.privateEndpointsSubnetName
  resource_group_name  = azurerm_resource_group.spokeResourceGroup.name
  virtual_network_name = module.vnet.vnetName
}

data "azurerm_subnet" "appGatewaySubnet" {
  count = var.applicationGatewaySubnetAddressPrefix != "" ? 1 : 0
  depends_on = [
    module.vnet
  ]
  name                 = var.applicationGatewaySubnetName
  resource_group_name  = azurerm_resource_group.spokeResourceGroup.name
  virtual_network_name = module.vnet.vnetName
}