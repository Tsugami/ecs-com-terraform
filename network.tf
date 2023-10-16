data "aws_vpc" "main" {
  id = var.vpc
}

data "aws_subnet" "subnet_1a" {
  id = var.subnet_1a
}

data "aws_subnet" "subnet_1b" {
  id = var.subnet_1b
}
