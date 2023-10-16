provider "aws" {
  region = var.region
}


data "aws_availability_zones" "available" {}

locals {
  name = "alura-ecs-${var.env}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    ManagedBy  = "Terraform"
    Enviroment = var.env
    Repository = "https://github.com/Tsugami/alura-ecs-com-terraform"
  }
}
