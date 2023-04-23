resource "azurerm_container_app_environment" "aca_environment" {
  name                       = "aca-environment"
  location                   = data.terraform_remote_state.spoke.outputs.rg.location
  resource_group_name        = data.terraform_remote_state.spoke.outputs.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
}

resource "azurerm_container_app" "aca" {
  name                         = "aca-app"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  resource_group_name          = azurerm_container_app_environment.aca_environment.resource_group_name
  revision_mode                = "Single"

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      label      = "examplecontainerapp"
      percentage = 100
    }
  }

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "storage1aca13579"
  resource_group_name      = data.terraform_remote_state.spoke.outputs.rg.name
  location                 = data.terraform_remote_state.spoke.outputs.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "file_share" {
  name                 = "sharename"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 5
}

resource "azurerm_container_app_environment_storage" "aca_storage" {
  name                         = "mycontainerappstorage"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  account_name                 = azurerm_storage_account.storage.name
  share_name                   = azurerm_storage_share.file_share.name
  access_key                   = azurerm_storage_account.storage.primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_container_app_environment_dapr_component" "dapr" {
  name                         = "example-component"
  container_app_environment_id = azurerm_container_app_environment.aca_environment.id
  component_type               = "state.azure.blobstorage"
  version                      = "v1"
}

# user identity

resource "azurerm_user_assigned_identity" "identity_aca" {
  name                = "identity-aca"
  resource_group_name = data.terraform_remote_state.spoke.outputs.rg.name
  location            = data.terraform_remote_state.spoke.outputs.rg.location
}

resource "azurerm_role_assignment" "role_acrpull_identity_aca" {
  scope                = data.terraform_remote_state.supporting_services.outputs.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity_aca.principal_id
}