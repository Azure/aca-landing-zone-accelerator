data "terraform_remote_state" "spoke" {
  backend = "local"

  config = {
    path = "../02-spoke/terraform.tfstate"
  }
}