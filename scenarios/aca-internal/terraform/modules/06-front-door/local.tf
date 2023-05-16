locals {
  containerAppsDefaultDomainArray   = split(var.containerAppsDefaultDomainName, ".")
  containerAppsNameIdentifier       = local.containerAppsDefaultDomainArray[index(local.containerAppsDefaultDomainArray, var.location)]
  containerAppsManagedResourceGroup = "MC_${local.containerAppsNameIdentifier}-rg_${local.containerAppsNameIdentifier}_${var.location}"

  containerAppsEnvironmentTokens         = split("/", var.containerAppsEnvironmentId)
  containerAppsEnvironmentSubscriptionId = local.containerAppsEnvironmentTokens[2]
  containerAppsEnvironmentResourceGroup  = local.containerAppsEnvironmentTokens[4]
  containerAppsEnvironmentName           = local.containerAppsEnvironmentTokens[8]
}