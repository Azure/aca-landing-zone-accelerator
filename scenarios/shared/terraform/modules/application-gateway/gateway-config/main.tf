resource "azurerm_public_ip" "appGatewayPip" {
  name                = var.appGatewayPublicIpName
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones = var.makeZoneRedundant == true? [
    "1",
    "2",
    "3"
  ]: []
  allocation_method   = "Static"
  ddos_protection_mode = var.ddosProtectionEnabled
  tags                = var.tags
}

resource "azurerm_application_gateway" "appGateway" {
  name                = var.appGatewayName
  resource_group_name = var.resourceGroupName
  location            = var.location
  identity {
    type         = "UserAssigned"
    identity_ids = [var.appGatewayUserAssignedIdentityId]
  }

  sku {
    name = var.skuName
    tier = var.skuTier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.appGatewaySubnetId
  }

  ssl_certificate {
    name                = var.appGatewayFQDN
    key_vault_secret_id = var.keyVaultSecretId
  }

  frontend_ip_configuration {
    name                          = "appGwPublicFrontendIp"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appGatewayPip.id
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  backend_address_pool {
    name  = "acaServiceBackend"
    fqdns = [var.appGatewayPrimaryBackendEndFQDN]
  }

  backend_http_settings {
    name                                = "defaultHttpBackendHttpSetting"
    port                                = 80
    protocol                            = "Http"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    request_timeout                     = 120
  }

  backend_http_settings {
    name                                = "https"
    port                                = 443
    protocol                            = "Https"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
    request_timeout                     = 20
    probe_name                          = "webProbe"
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    ssl_certificate_name           = var.appGatewayFQDN
    require_sni                    = false
  }

  request_routing_rule {
    name                       = "routingRules"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "acaServiceBackend"
    backend_http_settings_name = "https"
    priority                   = 10000 # value from 1 to 20000, required when sku.0.tier is set to *_v2
  }

  probe {
    name                                      = "webProbe"
    protocol                                  = "Https"
    host                                      = var.appGatewayPrimaryBackendEndFQDN
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    minimum_servers                           = 0
    match {
      status_code = ["200-499"]
    }
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0"
    request_body_check       = true
    max_request_body_size_kb = 128
    file_upload_limit_mb     = 100
  }

  enable_http2 = true
  autoscale_configuration {
    min_capacity = 2
    max_capacity = 3
  }
}

//need diagnostics settings

resource "azurerm_monitor_diagnostic_setting" "name" {
  name                       = var.diagnosticSettingName
  target_resource_id         = azurerm_application_gateway.appGateway.id
  log_analytics_workspace_id = var.appGatewayLogAnalyticsId

  enabled_log {
    category_group = "allLogs"
    retention_policy {
      enabled = true
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
}
