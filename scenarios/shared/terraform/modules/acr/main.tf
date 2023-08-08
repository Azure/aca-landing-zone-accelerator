resource "azurerm_container_registry" "acr" {
  name                = var.acrName
  resource_group_name = var.spokeResourceGroupName
  location            = var.location
  tags                = var.tags

  sku = "Premium"

  admin_enabled                 = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
}

module "containerRegistryPrivateZones" {
  source            = "../networking/private-zones"
  resourceGroupName = var.hubResourceGroupName
  vnetLinks         = var.vnetLinks
  zoneName          = local.privateDnsZoneNames
  records           = var.aRecords
  tags              = var.tags
}

module "containerRegistryPrivateEndpoints" {
  source            = "../networking/private-endpoints"
  endpointName      = var.containerRegistryPep
  resourceGroupName = var.spokeResourceGroupName
  subnetId          = var.subnetId
  privateLinkId     = azurerm_container_registry.acr.id
  privateDnsZoneIds = [module.containerRegistryPrivateZones.privateDnsZoneId]
  subResourceNames  = local.subResourceNames
  tags              = var.tags
}

resource "azurerm_user_assigned_identity" "containerRegistryUserAssignedIdentity" {
  name                = var.containerRegistryUserAssignedIdentityName
  resource_group_name = var.spokeResourceGroupName
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "containerRegistryPullRoleAssignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.containerRegistryUserAssignedIdentity.principal_id
}