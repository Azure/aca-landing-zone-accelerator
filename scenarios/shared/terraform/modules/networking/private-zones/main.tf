resource "azurerm_private_dns_zone" "privDnsZone" {
    name = var.zoneName
    resource_group_name = var.resourceGroupName
    tags = var.tags
}

### Need logic here
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name = "${var.vnetName}-link"
  resource_group_name = var.resourceGroupName
  private_dns_zone_name = azurerm_private_dns_zone.privDnsZone.name
  virtual_network_id = var.virtualNetworkId
  registration_enabled = var.registrationEnabled

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "aRecords" {
    for_each = var.aRecords
    zone_name = azurerm_private_dns_zone.privDnsZone.name
    resource_group_name = var.resourceGroupName

    name = each.value.name
    ttl = each.value.ttl
    records = each.value.records

    tags = var.tags
    
}

#### Logic needed here to create A records
# for_each = 
# dynamic "subnet" {
#         for_each = [for subnet in var.subnets: {
#             name = subnet.name
#             address_prefix = subnet.address_prefix
#         }]

#         content {
#           name = subnet.value.name
#           address_prefix = subnet.value.prefix
#         }
#     }
# dynamic "records" {
#     for_each = [for a_record in var.records:
#         resource "azurerm_dns_a_record" "dnsRecord" {
    
#     }
#     ]
# }

