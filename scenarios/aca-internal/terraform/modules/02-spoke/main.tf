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
  subnets           = local.spokeSubnets
}

module "nsgContainerAppsEnvironmentNsg" {
  source            = "../../../../shared/terraform/modules/networking/nsg"
  nsgName           = module.naming.resourceNames["containerAppsEnvironmentNsg"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  securityRules     = var.containerAppsSecurityRules
  tags              = var.tags
}

resource "azurerm_subnet_network_security_group_association" "infraSecurityGroupAssociation" {
  subnet_id                 = module.vnet.subnets[var.infraSubnetName].id
  network_security_group_id = module.nsgContainerAppsEnvironmentNsg.nsgId
}

module "nsgPrivateEndpoints" {
  source            = "../../../../shared/terraform/modules/networking/nsg"
  nsgName           = module.naming.resourceNames["privateEndpointsNsg"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  tags              = var.tags
}

resource "azurerm_subnet_network_security_group_association" "privateEndpointSecurityGroupAssociation" {
  subnet_id                 = module.vnet.subnets[var.privateEndpointsSubnetName].id
  network_security_group_id = module.nsgPrivateEndpoints.nsgId
}

module "nsgAppGateway" {
  source            = "../../../../shared/terraform/modules/networking/nsg"
  nsgName           = module.naming.resourceNames["applicationGatewayNsg"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  securityRules     = var.appGatewaySecurityRules
  tags              = var.tags
}

resource "azurerm_subnet_network_security_group_association" "agwSecurityGroupAssociation" {
  count                     = var.applicationGatewaySubnetAddressPrefix != "" ? 1 : 0
  subnet_id                 = module.vnet.subnets[var.applicationGatewaySubnetName].id
  network_security_group_id = module.nsgAppGateway.nsgId
}

module "nsgJumpbox" {
  source            = "../../../../shared/terraform/modules/networking/nsg"
  nsgName           = module.naming.resourceNames["vmJumpBoxNsg"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  tags              = var.tags
}

resource "azurerm_subnet_network_security_group_association" "jumpBoxSecurityGroupAssociation" {
  count                     = var.jumpboxSubnetAddressPrefix != "" ? 1 : 0
  subnet_id                 = module.vnet.subnets[var.jumpboxSubnetName].id
  network_security_group_id = module.nsgJumpbox.nsgId
}

module "routeTable" {
  source            = "../../../../shared/terraform/modules/networking/route-table"
  routeTableName    = module.naming.resourceNames["routeTable"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  tags              = var.tags

  routes = [
    {
      name               = "routeToFirewall"
      addressPrefix      = "0.0.0.0/0"
      nextHopType        = "VirtualAppliance" # "VirtualNetworkGateway"
      nextHopInIpAddress = var.firewall_private_ip_address
    }
  ]
}

resource "azurerm_subnet_route_table_association" "routeTableInfraSubnetAssociation" {
  subnet_id      = module.vnet.subnets[var.infraSubnetName].id
  route_table_id = module.routeTable.routeTableId
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

module "vm" {
  source                = "../../../../shared/terraform/modules/vms"
  osType                = "Linux"
  location              = var.location
  tags                  = var.tags
  nicName               = module.naming.resourceNames["vmJumpBoxNic"]
  vmName                = module.naming.resourceNames["vmJumpBox"]
  adminUsername         = var.vmAdminUsername
  adminPassword         = var.vmAdminPassword
  resourceGroupName     = azurerm_resource_group.spokeResourceGroup.name
  size                  = var.vmSize
  vnetResourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  subnetId              = module.vnet.subnets[var.jumpboxSubnetName].id
}

module "logAnalyticsWorkspace" {
  source            = "../../../../shared/terraform/modules/monitoring/log-analytics"
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  location          = var.location
  workspaceName     = module.naming.resourceNames["logAnalyticsWorkspace"]
  tags              = var.tags
}

module "diagnostics" {
  source                  = "../../../../shared/terraform/modules/diagnostics"
  logAnalyticsWorkspaceId = module.logAnalyticsWorkspace.id
  resources = [
    {
      type = "vnet-spoke"
      id   = module.vnet.vnetId
    }
    # todo : VM Diagnoistic Settings needs first to install an agent/extension AMA on the VM
    # https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage?tabs=azure-portal
    # { 
    #   type = "vm-jumpbox"
    #   id   = module.vm.vmId
    # }
  ]
}
