data "azurerm_lb" "lb" {
  name                = "kubernetes-internal"
  resource_group_name = var.containerAppsManagedResourceGroup
}

resource "azurerm_private_link_service" "privateLinkService" {
  name                                        = var.privateLinkServiceName
  resource_group_name                         = var.resourceGroupName
  location                                    = var.location
  load_balancer_frontend_ip_configuration_ids = data.azurerm_lb.lb.frontend_ip_configuration.0.id
  nat_ip_configuration {
    name                       = "snet-provider-default-1"
    primary                    = true
    private_ip_address_version = "IPv4"
    subnet_id                  = var.privateLinkSubnetId
  }
}

data "azurerm_private_link_service_endpoint_connections" "privateEndpointConnections" {
  service_id          = azurerm_private_link_service.privateLinkService.id
  resource_group_name = azurerm_private_link_service.privateLinkService.resource_group_name
}

resource "azurerm_cdn_frontdoor_profile" "frontDoorProfile" {
  depends_on = [
    azurerm_private_link_service.privateLinkService
  ]
  name                     = var.frontDoorProfileName
  resource_group_name      = var.resourceGroupName
  sku_name                 = "Premium_AzureFrontDoor"
  response_timeout_seconds = 120
}

resource "azurerm_cdn_frontdoor_endpoint" "frontDoorEndpoint" {
  name                     = var.frontDoorEndpointName
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontDoorProfile.id
  enabled                  = true
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "frontDoorOriginGroup" {
  name                     = var.frontDoorOriginGroupName
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontDoorProfile.id
  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    path                = "/health"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }

  session_affinity_enabled = false
}

resource "azurerm_cdn_frontdoor_origin" "frontDoorOrigin" {
  name                          = var.frontDoorOriginName
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontDoorOriginGroup.id
  host_name                     = var.frontDoorHostName
  http_port                     = 80
  https_port                    = 443
  origin_host_header            = var.frontDoorHostName
  priority                      = 1
  weight                        = 100
  enabled                       = true

  private_link {
    request_message        = "frontdoor"
    private_link_target_id = azurerm_private_link_service.privateLinkService.id
    location               = azurerm_private_link_service.privateLinkService.location
  }

  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "frontDoorOriginRoute" {
  name                          = var.frontDoorRouteName
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontDoorOriginGroup.id
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontDoorEndpoint.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontDoorOrigin.id]
  cdn_frontdoor_origin_path     = "/"
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  https_redirect_enabled        = true
  enabled                       = true
}