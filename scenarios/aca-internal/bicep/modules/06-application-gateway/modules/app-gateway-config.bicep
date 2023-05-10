targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------
param appGatewayName string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFqdn string
@description('The subnet resource id to use for Application Gateway.')
param appGatewaySubnetId string
param appGatewayPrimaryBackendEndFqdn string
param appGatewayBackendHealthProbePath string

param appGatewayUserAssignedIdentityId string
param appGatewayPublicIpName string

@description('Provide a resource ID of the Web Analytics WS if you need diagnostic settngs, or nothing if you don t need any')
param appGatewayLogAnalyticsId string

@secure()
param keyVaultSecretId string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

param location string = resourceGroup().location

// ------------------
// VARIABLES
// ------------------


// ------------------
// RESOURCES
// ------------------

resource appGatewayPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: appGatewayPublicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: appGatewayName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appGatewayUserAssignedIdentityId}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnetId
          }
        }
      }
    ]
    sslCertificates: (!empty(keyVaultSecretId)) ? [
      {
        name: appGatewayFqdn
        properties: {
          keyVaultSecretId: keyVaultSecretId
        }
      }
    ] : []
    trustedRootCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGatewayPip.id
          }
        }
      }
    ]
    frontendPorts: (!empty(keyVaultSecretId)) ? [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ] : [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'acaServiceBackend'
        properties: {
          backendAddresses: [
            {
              fqdn: appGatewayPrimaryBackendEndFqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'defaultHttpBackendHttpSetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 120
          // probe: {
          //   id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'webProbe')
          // }
        }
      }
      {
        name: 'https'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'webProbe')
          }
        }
      }
    ]
    httpListeners: (empty(keyVaultSecretId)) ? [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostnames: []
          requireServerNameIndication: false
        }
      }
    ] : [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/sslCertificates/${appGatewayFqdn}'
          }
          hostnames: []
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'routingRules'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/httpListeners/httpListener'
          }
          backendAddressPool: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/backendAddressPools/acaServiceBackend'
          }
          backendHttpSettings: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/backendHttpSettingsCollection/https'
          }
        }
      }
    ]
    probes: [
      {
        name: 'webProbe'
        properties: {
          protocol: 'Https'
          host: appGatewayPrimaryBackendEndFqdn
          path: appGatewayBackendHealthProbePath
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-499'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 3
    }
  }
}

resource agwDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(appGatewayLogAnalyticsId)) {
  name: 'agw-diagnostics-${uniqueString(resourceGroup().id)}'
  scope: appGateway
  properties: {
    workspaceId: appGatewayLogAnalyticsId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The FQDN of the application gateway.')
output applicationGatewayFqdn string = appGatewayFqdn

@description('The public IP address of the application gateway.')
output applicationGatewayPublicIp string = appGatewayPip.properties.ipAddress
