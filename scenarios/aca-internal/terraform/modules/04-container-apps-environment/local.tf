locals {
  hubTokens            = split("/", var.hubVnetId)
  hubSubscriptionId    = local.hubTokens[2]
  hubVnetResourceGroup = local.hubTokens[4]
  hubVnetName          = local.hubTokens[8]

  spokeTokens            = split("/", var.spokeVnetId)
  spokeSubscriptionId    = local.spokeTokens[2]
  spokeVnetResourceGroup = local.spokeTokens[4]
  spokeVnetName          = local.spokeTokens[8]


  vnetLinks = [
    {
      "name"                = local.spokeVnetName
      "vnetId"              = var.spokeVnetId
      "resourceGroupName"   = local.spokeVnetResourceGroup
      "registrationEnabled" = false
    },
    {
      "name"                = local.hubVnetName
      "vnetId"              = var.hubVnetId
      "resourceGroupName"   = local.hubVnetResourceGroup
      "registrationEnabled" = false
    }
  ]

}