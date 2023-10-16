

variable "env" {
  description = "value of environment"
  type        = string
}

variable "region" {
  description = "value of region"
  type        = string
}

variable "vpc" {
  description = "value of vpc"
  type        = string
}

variable "subnet_1a" {
  description = "value of subnet_a1"
  type        = string
}

variable "subnet_1b" {
  description = "value of subnet_a2"
  type        = string
}

variable "instance_type" {
  description = "value of instance_type"
  default     = "t2.micro"
  type        = string
}

variable "image_id" {
  description = "value of image_id"
  default     = "ami-062c116e449466e7f"
  type        = string
}
