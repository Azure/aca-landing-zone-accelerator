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

  dynamic "gateway_ip_configuration" {
    for_each = var.gatewayIPConfigurations
    content {
      name      = gateway_ip_configuration.value.name
      subnet_id = gateway_ip_configuration.value.subnet_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backendAddressPools
    content {
      name  = backend_address_pool.value.name
      fqdns = backend_address_pool.value.fqdns
    }
  }
  
  dynamic "ssl_certificate" {
    for_each = var.sslCertificates
    content {
      name                = ssl_certificate.value.name
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontendIPConfigurations
    content {
      name                          = frontend_ip_configuration.value.name
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontendPorts
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backendHttpSettings
    content {
      name = backend_http_settings.value.name
      port = backend_http_settings.value.port
      protocol = backend_http_settings.value.protocol
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      request_timeout = backend_http_settings.value.request_timeout
      probe_name = backend_http_settings.value.probe_name    
    }
  }

  dynamic "http_listener" {
    for_each = var.httpListeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      require_sni                    = http_listener.value.require_sni
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.requestRoutingRules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                   = request_routing_rule.value.priority
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      host                                      = probe.value.host
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers
      match {
        status_code = [probe.value.match.status_code]
      }
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
  dynamic "autoscale_configuration" {
    for_each = var.autoScaleSettings
    content {
        min_capacity = var.autoscaleMinCapacity == -1? null: var.autoscaleMinCapacity
        max_capacity = var.autoscaleMaxCapacity == -1? null: var.autoscaleMaxCapacity
    }
  }

  zones = var.makeZoneRedundant == true? var.zones: []
}
