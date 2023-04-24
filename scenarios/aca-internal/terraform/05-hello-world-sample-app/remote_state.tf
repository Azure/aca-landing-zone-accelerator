data "terraform_remote_state" "container_apps_environment" {
  backend = "local"

  config = {
    path = "../04-container-apps-environment/terraform.tfstate"
  }
}