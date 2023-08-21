resource "azurerm_public_ip" "appGatewayPip" {
  name                = var.appGatewayPublicIpName
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "Standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
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
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.appGatewaySubnetId
  }

  //logic
  # dynamic "ssl_certificate" {
  #   for_each = var.sslCertificates
  #   content {
  #     name                = ssl_certificate.value.name
  #     data                = ssl_certificate.value.data
  #     password            = ssl_certificate.value.password
  #     key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
  #   }
  # }

  // May need some new logic here
  ssl_certificate {
    name                = var.appGatewayFQDN
    key_vault_secret_id = var.keyVaultSecretId
  }

  frontend_ip_configuration {
    name                          = "appGwPublicFrontendIp"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appGatewayPip.id
  }

  # dynamic "frontend_port" {
  #   for_each = var.frontendPorts
  #   content {
  #     name = frontend_port.value.name
  #     port = lookup(frontend_port.value, "port", null)
  #   }
  # }
  // May need some logic here
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

  // Missing probe name
  # dynamic "backend_http_settings" {
  #   for_each = var.backendHttpSettings
  #   content {
  #     port                                = backend_http_settings.value.port
  #     protocol                            = backend_http_settings.value.protocol
  #     name                                = backend_http_settings.value.name
  #     cookie_based_affinity               = backend_http_settings.value.cookieBasedAffinity
  #     pick_host_name_from_backend_address = true
  #     affinity_cookie_name                = backend_http_settings.value.affinityCookieName
  #     request_timeout                     = backend_http_settings.value.requestTimeout
  #   }
  # }

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
  # dynamic "http_listener" {
  #   for_each = var.httpListeners
  #   content {
  #     frontend_ip_configuration_name =  http_listener.value.frontendIp
  #     frontend_port_name = ""
  #     protocol = ""
  #     ssl_certificate_name = ""
  #     require_sni = false
  #   }
  # }

  // may need some logic here
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    ssl_certificate_name           = var.appGatewayFQDN
    require_sni                    = false
  }

  # dynamic "request_routing_rule" {
  #       for_each = var.requestRoutingRules
  #       content {
  #         name = ""
  #         rule_type = ""
  #         http_listener_name = ""
  #         backend_address_pool_name = ""
  #         backend_http_settings_name = ""
  #       }
  # }
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
