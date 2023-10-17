resource "aws_ecs_task_definition" "this" {
  family                = "${var.service_name}-family"
  network_mode          = var.task_definition.network_mode
  cpu                   = var.task_definition.cpu
  container_definitions = var.task_definition.container_definitions

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.service_name}-tg"
  port        = var.load_balancer.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count


  capacity_provider_strategy {
    weight            = var.aws_ecs_capacity_provider.weight
    capacity_provider = var.aws_ecs_capacity_provider.name
  }

  load_balancer {
    container_name   = var.load_balancer.container_name
    container_port   = var.load_balancer.container_port
    target_group_arn = aws_lb_target_group.this.arn
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  network_configuration {
    subnets         = var.network.subnets
    security_groups = var.network.security_groups
  }

  triggers = {
    redeployment = timestamp()
  }
}
