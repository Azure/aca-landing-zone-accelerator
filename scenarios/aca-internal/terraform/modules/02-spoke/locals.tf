locals {
  hubTokens            = split("/", var.hubVnetId)
  hubSubscriptionId    = local.hubTokens[2]
  hubVnetResourceGroup = local.hubTokens[4]
  hubVnetName          = local.hubTokens[8]

  defaultSubnets = [
    { "name"            = var.infraSubnetName
      "addressPrefixes" = tolist([var.infraSubnetAddressPrefix])
    },
    {
      "name"            = var.privateEndpointsSubnetName
      "addressPrefixes" = tolist([var.privateEndpointsSubnetAddressPrefix])
    }
  ]

  subnets = var.applicationGatewaySubnetAddressPrefix != "" ? concat(local.defaultSubnets, [{ "name" = var.applicationGatewaySubnetName
  "addressPrefixes" = tolist([var.applicationGatewaySubnetAddressPrefix]) }]) : local.defaultSubnets
}