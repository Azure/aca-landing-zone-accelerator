output "containerAppsEnvironmentName" {
  value = azapi_resource.container_apps_environment.name
}

output "containerAppsEnvironmentId" {
  value = azapi_resource.container_apps_environment.id
}

output "containerAppsEnvironmentDefaultDomain" {
  value = jsondecode(azapi_resource.container_apps_environment.output).properties.defaultDomain
}

output "containerAppsEnvironmentLoadBalancerIP" {
  value = jsondecode(azapi_resource.container_apps_environment.output).properties.staticIp
}
