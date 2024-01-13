locals {
  hubTokens            = split("/", var.hubVnetId)
  hubSubscriptionId    = local.hubTokens[2]
  hubVnetResourceGroup = local.hubTokens[4]
  hubVnetName          = local.hubTokens[8]

  defaultSubnets = [
    {
      name            = var.infraSubnetName
      addressPrefixes = tolist([var.infraSubnetAddressPrefix])
    },
    {
      name            = var.privateEndpointsSubnetName
      addressPrefixes = tolist([var.privateEndpointsSubnetAddressPrefix])
    }
  ]

  appGatewayandDefaultSubnets = var.applicationGatewaySubnetAddressPrefix != "" ? concat(
    local.defaultSubnets,
    [{
      name            = var.applicationGatewaySubnetName
      addressPrefixes = tolist([var.applicationGatewaySubnetAddressPrefix])
    }]
  ) : local.defaultSubnets

  spokeSubnets = var.vmJumpboxOSType != "none" ? concat(
    local.appGatewayandDefaultSubnets,
    [{
      name            = var.jumpboxSubnetName
      addressPrefixes = tolist([var.jumpboxSubnetAddressPrefix])
    }]
  ) : local.appGatewayandDefaultSubnets

  subnetDelegations = {
    "${var.infraSubnetName}" = {
      "Microsoft.App/environments" = {
        service_name = "Microsoft.App/environments"
        service_actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }
}
