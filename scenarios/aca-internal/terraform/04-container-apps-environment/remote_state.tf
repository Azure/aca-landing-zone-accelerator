data "terraform_remote_state" "spoke" {
  backend = "local"

  config = {
    path = "../02-spoke/terraform.tfstate"
  }
}

data "terraform_remote_state" "supporting_services" {
  backend = "local"

  config = {
    path = "../03-supporting-services/terraform.tfstate"
  }
}