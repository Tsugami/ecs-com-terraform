provider "aws" {
  region = var.region
}

locals {
  name = "alura-ecs-${var.env}"
  tags = {
    ManagedBy  = "Terraform"
    Enviroment = var.env
    Repository = "https://github.com/Tsugami/alura-ecs-com-terraform"
  }
}
