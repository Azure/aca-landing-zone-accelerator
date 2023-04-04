## Virtual Network

resource "azurerm_virtual_network" "vnet" {
    name = var.network_name
    location = var.location
    resource_group_name = var.resource_group_name
    address_space = var.address_space
    ddos_protection_plan  {
        enable = var.ddos_protection_plan_id != ""? true: false
        id = var.ddos_protection_plan_id != ""? var.ddos_protection_plan_id: null
    }

    tags = var.tags

    dynamic "subnet" {
        for_each = [for subnet in var.subnets: {
            name = subnet.name
            address_prefix = subnet.address_prefix
        }]

        content {
          name = subnet.value.name
          address_prefix = subnet.value.prefix
        }
    }
}