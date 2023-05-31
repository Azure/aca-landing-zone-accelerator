targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

param frontDoorProfileName string
param frontDoorEndpointName string
param frontDoorOriginGroupName string
param frontDoorOriginName string
param frontDoorOriginRouteName string

@description('Private Link Service Id')
param privateLinkServiceId string

@description('The host name of the origin.')
param frontDoorOriginHostName string

// ------------------
// RESOURCES
// ------------------

resource frontDoorProfile 'Microsoft.Cdn/profiles@2022-05-01-preview' = {
  name: frontDoorProfileName
  tags: tags
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 120
    extendedProperties: {}
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdendpoints@2022-05-01-preview' = {
  parent: frontDoorProfile
  name: frontDoorEndpointName
  tags: tags
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/origingroups@2022-05-01-preview' = {
  parent: frontDoorProfile
  name: frontDoorOriginGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/origingroups/origins@2022-05-01-preview' = {
  parent: frontDoorOriginGroup
  name: frontDoorOriginName
  properties: {
    hostName: frontDoorOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: frontDoorOriginHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    sharedPrivateLinkResource: {
      privateLink: {
        id: privateLinkServiceId
      }
      privateLinkLocation: location
      requestMessage: 'frontdoor'
    }
    enforceCertificateNameCheck: true
  }
}

resource frontDoorOriginRoute 'Microsoft.Cdn/profiles/afdendpoints/routes@2022-05-01-preview' = {
  parent: frontDoorEndpoint
  name: frontDoorOriginRouteName
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    originPath: '/'
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }

  dependsOn: [
    frontDoorOrigin
  ]
}

@description('The host name of the front door endpoint.')
output fqdn string = frontDoorEndpoint.properties.hostName
