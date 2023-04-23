data "terraform_remote_state" "hub" {
  backend = "local" # "remote"

  config = {
    path = "../01-hub/terraform.tfstate"
  }
}

# todo: use remote state
# data "terraform_remote_state" "existing-hub" {
#   backend = "azurerm"

#   config = {
#     storage_account_name = var.state_sa_name
#     container_name       = var.container_name
#     key                  = "hub-net"
#     access_key           = var.access_key
#   }
# }