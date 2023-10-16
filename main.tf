provider "aws" {
  region = var.region
}


locals {
  tags = {
    ManagedBy  = "Terraform"
    Enviroment = var.env
    Repository = "https://github.com/Tsugami/alura-ecs-com-terraform"
  }
}
