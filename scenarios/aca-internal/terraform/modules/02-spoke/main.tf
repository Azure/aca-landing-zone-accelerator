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
  subnetDelegations = local.subnetDelegations
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
  subnet_id                 = data.azurerm_subnet.infraSubnet.id
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
  subnet_id                 = data.azurerm_subnet.privateEndpointsSubnet.id
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
  subnet_id                 = data.azurerm_subnet.appGatewaySubnet[0].id
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
  subnet_id                 = data.azurerm_subnet.jumpboxSubnet[0].id
  network_security_group_id = module.nsgJumpbox.nsgId
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
  sshAuthorizedKeys     = var.vmLinuxSshAuthorizedKeys
  authenticationType    = var.vmLinuxAuthenticationType
  resourceGroupName     = azurerm_resource_group.spokeResourceGroup.name
  size                  = var.vmSize
  vnetResourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  subnetId              = data.azurerm_subnet.jumpboxSubnet[0].id
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
  logAnalyticsWorkspaceId = module.logAnalyticsWorkspace.workspaceId
  resources = [
    {
      type = "vnet-spoke"
      id   = module.vnet.vnetId
    },
    {
      type = "vm-jumpbox"
      id   = module.vm.vmId
    }
  ]
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

data "azurerm_subnet" "jumpboxSubnet" {
  count = var.jumpboxSubnetAddressPrefix != "" ? 1 : 0
  depends_on = [
    module.vnet
  ]

  name                 = var.jumpboxSubnetName
  resource_group_name  = azurerm_resource_group.spokeResourceGroup.name
  virtual_network_name = module.vnet.vnetName
}

module "routeTable" {
  source            = "../../../../shared/terraform/modules/networking/route-table"
  routeTableName    = module.naming.resourceNames["routeTable"]
  location          = var.location
  resourceGroupName = azurerm_resource_group.spokeResourceGroup.name
  subnetId          = data.azurerm_subnet.infraSubnet.id
  tags              = var.tags

  routes = concat(
    [{
      name             = "defaultEgressLockdown"
      addressPrefix    = "0.0.0.0/0"
      nextHopType      = "VirtualAppliance"
      nextHopIpAddress = var.firewallPrivateIp
    },
    var.routeSpokeTrafficInternally ? [for i, prefix in var.vnetAddressPrefixes : {
      name            = "spokeInternalTraffic-${i}"
      addressPrefix   = prefix
      nextHopType     = "VnetLocal"
    }] : []
  ])
}
