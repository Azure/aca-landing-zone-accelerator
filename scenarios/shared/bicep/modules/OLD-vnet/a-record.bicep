param envstaticip string
param recordName string
param privateDNSZoneName string




resource record 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateDNSZoneName}/${recordName}'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: envstaticip
      }
    ]
  }
}
