locals {
  hubTokens            = split("/", var.hubVnetId)
  hubSubscriptionId    = local.hubTokens[2]
  hubVnetResourceGroup = local.hubTokens[4]
  hubVnetName          = local.hubTokens[8]

  # defaultSubnets = [
  #   {
  #     name               = var.infraSubnetName
  #     addressPrefixes    = var.infraSubnetAddressPrefix
  #     service_delegation = null
  #     # service_delegation = [{
  #     #   name    = "Microsoft.App/environments"
  #     #   actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #     # }]
  #   },
  #   {
  #     name               = var.privateEndpointsSubnetName
  #     addressPrefixes    = var.privateEndpointsSubnetAddressPrefix
  #     service_delegation = null
  #   }
  # ]

  # appGatewayandDefaultSubnets = var.applicationGatewaySubnetAddressPrefix != "" ? concat(local.defaultSubnets, [
  #   {
  #     name               = var.applicationGatewaySubnetName
  #     addressPrefixes    = var.applicationGatewaySubnetAddressPrefix
  #     service_delegation = null
  #   }
  # ]) : local.defaultSubnets

  # spokeSubnets = var.vmJumpboxOSType != "none" ? concat(local.appGatewayandDefaultSubnets, [
  #   {
  #     name               = var.jumpboxSubnetName
  #     addressPrefixes    = var.jumpboxSubnetAddressPrefix
  #     service_delegation = null
  #   }
  # ]) : local.appGatewayandDefaultSubnets

  spokeSubnets = [
    {
      name               = var.infraSubnetName
      addressPrefixes    = var.infraSubnetAddressPrefix
      service_delegation = null
      service_delegation = [{
        name    = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }]
    },
    {
      name               = var.privateEndpointsSubnetName
      addressPrefixes    = var.privateEndpointsSubnetAddressPrefix
      service_delegation = null
    },
    {
      name               = var.applicationGatewaySubnetName
      addressPrefixes    = var.applicationGatewaySubnetAddressPrefix
      service_delegation = null
    },
    {
      name               = var.jumpboxSubnetName
      addressPrefixes    = var.jumpboxSubnetAddressPrefix
      service_delegation = null
    }
  ]
}
