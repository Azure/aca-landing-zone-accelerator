// TODO: Work in progress

@description('The name of the Application Gateawy to be created')
@minLength(5)
@maxLength(80)
param name string

@description('Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN string

@description('The subnet resource id to use for Application Gateway.')
param appGatewaySubnetId string

@description('The backend URL.')
param primaryBackendEndFQDN string

@description('the name of the self signed certificate in key vault (i.e. acahello-demoapp-com)')
param certificateKeyName string

@description('The keyvault name, that holds the certificate for the application Gateway')
param keyvaultName string

@secure()
param keyVaultSecretId string


// param keyvaultAppGWCertRG string

var appGatewayPrimaryPip = 'pip-${name}'
var appGatewayIdentityId = 'id-${name}'
var webPath = '/'

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     appGatewayIdentityId
  location: location
}

resource keyvaultAppGw 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyvaultName
  // scope: resourceGroup(keyvaultAppGWCertRG) 
}

module kvRoleSecretsUser '../../shared/bicep/modules/role-assignments/role-assignment.bicep' = {
  name: 'kvRoleSecretsUserDeployment'
  params: {
    resourceId: keyvaultAppGw.id
    principalId: appGatewayIdentity.properties.principalId
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'  //Key Vault Secrets User
  }
}

resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: '${keyvaultAppGw.name}/add'
  properties: {
    accessPolicies: [
      {
        objectId: appGatewayIdentity.properties.principalId
        tenantId: appGatewayIdentity.properties.tenantId
        permissions: {
          secrets: [ 
            'get' 
            'list'
          ]
          certificates: [
            'import'
            'get'
            'list'
            'update'
            'create'
          ]
        }                  
      }
    ]
  }
}

module pipAppGw '../../shared/bicep/modules/network/publicIp.bicep' = {
  name: 'pipAppGwDeployment'
  params: {
    location: location
    name: appGatewayPrimaryPip
    tags: tags
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
  }
}

resource appGatewayResource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appGatewayIdentity.id}': {}
    }
  }
  dependsOn: [
    kvRoleSecretsUser
    accessPolicyGrant
  ]
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
    sslCertificates: (!empty(certificateKeyName)) ? [
      {
        name: appGatewayFQDN
        properties: {
          keyVaultSecretId:  keyVaultSecretId 
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
            id: pipAppGw.outputs.pipResourceId
          }
        }
      }
    ]
    frontendPorts: (!empty(certificateKeyName))? [
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
              fqdn: primaryBackendEndFQDN
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
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 120
          probe:{
            id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'webProbe')
          }
        }
      }
      {
        name: 'https'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: primaryBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          // probe: {
          //   id: resourceId('Microsoft.Network/applicationGateways/probes', name, 'webProbe')
          // }
        }
      }
    ]
    httpListeners: (empty(certificateKeyName))?[
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostnames: []
          requireServerNameIndication: false
        }
      }
    ]:[
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/sslCertificates/${appGatewayFQDN}'
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
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/httpListeners/httpListener'
          }
          backendAddressPool: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/backendAddressPools/acaServiceBackend'
          }
          backendHttpSettings: {
            #disable-next-line use-resource-id-functions
            id: '${resourceId('Microsoft.Network/applicationGateways', name)}/backendHttpSettingsCollection/defaultHttpBackendHttpSetting'
          }
        }
      }
    ]
    probes: [
      {
        name: 'webProbe'
        properties: {
          protocol: 'Http'
          host: primaryBackendEndFQDN
          path: webPath
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
