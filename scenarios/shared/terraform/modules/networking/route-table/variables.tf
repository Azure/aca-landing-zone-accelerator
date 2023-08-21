variable "routeTableName" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "location" {
  type = string
}

variable "routes" {
  type = list(object({
    name               = string
    addressPrefix      = string
    nextHopType        = string
    nextHopInIpAddress = string
  }))
}

variable "tags" {
  type = map(string)
}
