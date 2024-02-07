resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
}

module "naming" {
  source       = "../../../../shared/terraform/modules/naming"
  uniqueId     = random_string.random.result
  environment  = var.environment
  workloadName = var.workloadName
  location     = var.location
}

resource "azurerm_user_assigned_identity" "appGatewayUserIdentity" {
  name                = module.naming.resourceNames["applicationGatewayUserAssignedIdentity"]
  location            = var.location
  resource_group_name = var.resourceGroupName # module.naming.resourceNames["rgSpokeName"]
  tags                = var.tags
}

resource "azurerm_public_ip" "appGatewayPip" {
  name                = module.naming.resourceNames["applicationGatewayPip"]
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones = var.makeZoneRedundant == true ? [
    "1",
    "2",
    "3"
  ] : []
  allocation_method    = "Static"
  ddos_protection_mode = var.ddosProtectionEnabled
  tags                 = var.tags
}

module "appGatewayAddCertificates" {
  source                                    = "../../../../shared/terraform/modules/application-gateway/certificate-config"
  keyVaultName                              = var.keyVaultName
  resourceGroupName                         = var.resourceGroupName
  appGatewayCertificateKeyName              = var.appGatewayCertificateKeyName
  appGatewayCertificateData                 = local.appGatewayCertificate
  appGatewayUserAssignedIdentityPrincipalId = azurerm_user_assigned_identity.appGatewayUserIdentity.principal_id
}

module "appGatewayConfiguration" {
  source                = "../../../../shared/terraform/modules/application-gateway/"
  appGatewayName        = module.naming.resourceNames["applicationGateway"]
  resourceGroupName     = var.resourceGroupName
  location              = var.location
  diagnosticSettingName = "agw-diagnostics"
  skuName               = "WAF_v2"
  skuTier               = "WAF_v2"
  gatewayIPConfigurations = [
    {
      name      = "appGatewayIpConfig"
      subnet_id = var.appGatewaySubnetId
  }]
  backendAddressPools = [
    {
      name  = "acaServiceBackend"
      fqdns = [var.appGatewayPrimaryBackendEndFQDN]
    }
  ]
  sslCertificates = [
    {
      name                = var.appGatewayFQDN
      key_vault_secret_id = module.appGatewayAddCertificates.SecretUri
    }
  ]
  frontendIPConfigurations = [
    {
      name                          = "appGwPublicFrontendIp"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.appGatewayPip.id
    }
  ]
  frontendPorts = var.enableAppGatewayCertificate ? [
    {
      name = "port_443"
      port = 443
    },
    {
      name = "port_80"
      port = 80
    }
    ] : [
    {
      name = "port_80"
      port = 80
    }
  ]
  backendHttpSettings = [
    {
      name                                = "https"
      cookie_based_affinity               = "Disabled"
      port                                = 443
      protocol                            = "Https"
      request_timeout                     = 20
      pick_host_name_from_backend_address = true
      probe_name                          = "webProbe"
    }
  ]
  httpListeners = !var.enableAppGatewayCertificate ? [
    {
      name                           = "httpListener"
      frontend_ip_configuration_name = "appGwPublicFrontendIp"
      frontend_port_name             = "port_80"
      protocol                       = "Http"
      require_sni                    = false
    }
    ] : [
    {
      name                           = "httpListener"
      frontend_ip_configuration_name = "appGwPublicFrontendIp"
      frontend_port_name             = "port_443"
      protocol                       = "Https"
      ssl_certificate_name           = var.appGatewayFQDN
      require_sni                    = false
    }
  ]
  requestRoutingRules = [
    {
      name                       = "routingRules"
      rule_type                  = "Basic"
      priority                   = 100
      http_listener_name         = "httpListener"
      backend_address_pool_name  = "acaServiceBackend"
      backend_http_settings_name = "https"
    }
  ]
  probes = [
    {
      name                                      = "webProbe"
      protocol                                  = "Https"
      host                                      = var.appGatewayPrimaryBackendEndFQDN
      path                                      = "/" # verify this
      interval                                  = 30
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = false
      minimum_servers                           = 0
      match = {
        status_code = "200-499"
      }
    }
  ]
  zones = var.makeZoneRedundant == true ? [
    "1",
    "2",
    "3"
  ] : []
  firewallConfiguration = {
    enabled                     = true
    mode                        = "Prevention"
    rule_set_type               = "OWASP"
    rule_set_version            = "3.0"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_mb        = 100
  }
  sslPolicyName                    = "AppGwSslPolicy20220101"
  sslPolicyType                    = "Predefined"
  appGatewayFQDN                   = var.appGatewayFQDN
  appGatewayPrimaryBackendEndFQDN  = var.appGatewayPrimaryBackendEndFQDN
  appGatewayPublicIpName           = module.naming.resourceNames["applicationGatewayPip"]
  appGatewaySubnetId               = var.appGatewaySubnetId
  appGatewayUserAssignedIdentityId = azurerm_user_assigned_identity.appGatewayUserIdentity.id
  keyVaultSecretId                 = module.appGatewayAddCertificates.SecretUri
  appGatewayLogAnalyticsId         = var.appGatewayLogAnalyticsId
  tags                             = var.tags
}

module "diagnostics" {
  source                  = "../../../../shared/terraform/modules/diagnostics"
  logAnalyticsWorkspaceId = var.logAnalyticsWorkspaceId
  resources = [
    {
      type = "agw"
      id   = module.appGatewayConfiguration.applicationGatewayId
    }
  ]
}