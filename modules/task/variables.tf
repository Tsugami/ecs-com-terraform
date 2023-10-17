
variable "service_name" {
  type = string
}

variable "task_definition" {
  type = object({
    network_mode          = string
    cpu                   = number
    container_definitions = string
  })
}

variable "cluster_id" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "aws_ecs_capacity_provider" {
  type = object({
    weight = optional(number, 100)
    name   = string
  })
}

variable "network" {
  type = object({
    subnets         = list(string)
    security_groups = list(string)
  })
}
