variable "resourceTypeAbbreviations" {
  type = map(string)
  default = {
    applicationGateway       = "agw"
    applicationInsights      = "appi"
    appService               = "app"
    bastion                  = "bas"
    containerAppsEnvironment = "cae"
    containerRegistry        = "cr"
    cosmosDbNoSql            = "cosno"
    frontDoor                = "afd"
    frontDoorEndpoint        = "fde"
    frontDoorWaf             = "fdfp"
    keyVault                 = "kv"
    logAnalyticsWorkspace    = "log"
    managedIdentity          = "id"
    networkInterface         = "nic"
    networkSecurityGroup     = "nsg"
    privateEndpoint          = "pep"
    privateLinkService       = "pls"
    publicIpAddress          = "pip"
    resourceGroup            = "rg"
    serviceBus               = "sb"
    serviceBusQueue          = "sbq"
    serviceBusTopic          = "sbt"
    storageAccount           = "st"
    virtualMachine           = "vm"
    virtualNetwork           = "vnet"
  }
}

variable "regionAbbreviations" {
  type = map(string)
  default = {
    australiacentral   = "auc"
    australiacentral2  = "auc2"
    australiaeast      = "aue"
    australiasoutheast = "ause"
    brazilsouth        = "brs"
    brazilsoutheast    = "brse"
    canadacentral      = "canc"
    canadaeast         = "cane"
    centralindia       = "cin"
    centralus          = "cus"
    centraluseuap      = "cuseuap"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    eastus2euap        = "eus2euap"
    francecentral      = "frc"
    francesouth        = "frs"
    germanynorth       = "gern"
    germanywestcentral = "gerwc"
    japaneast          = "jae"
    japanwest          = "jaw"
    jioindiacentral    = "jioinc"
    jioindiawest       = "jioinw"
    koreacentral       = "koc"
    koreasouth         = "kors"
    northcentralus     = "ncus"
    northeurope        = "neu"
    norwayeast         = "nore"
    norwaywest         = "norw"
    southafricanorth   = "san"
    southafricawest    = "saw"
    southcentralus     = "scus"
    southeastasia      = "sea"
    southindia         = "sin"
    swedencentral      = "swc"
    switzerlandnorth   = "swn"
    switzerlandwest    = "sww"
    uaecentral         = "uaec"
    uaenorth           = "uaen"
    uksouth            = "uks"
    ukwest             = "ukw"
    westcentralus      = "wcus"
    westeurope         = "weu"
    westindia          = "win"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
  }
}

variable "workloadName" {
  type = string
  validation {
    condition     = length(var.workloadName) >= 2 && length(var.workloadName) <= 10
    error_message = "Name must be greater at least 2 characters and not greater than 10."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = length(var.environment) <= 8
    error_message = "Environment name can't be greater than 8 characters long."
  }
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "uniqueId" {}

variable "resourceTypeToken" {
  default = "RES_TYPE"
}
