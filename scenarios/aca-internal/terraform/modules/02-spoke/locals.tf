locals {
    hubTokens = split("/", var.hubVnetId)
    hubSubscriptionId = hubTokens[2]
    hubVnetResourceGroup = hubTokens[4]
    hubVnetName = hubTokens[8]
}