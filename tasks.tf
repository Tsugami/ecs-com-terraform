
resource "aws_lb" "ecs" {
  name               = "${local.name}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.subnet_1a, var.subnet_1b]
  security_groups    = [aws_security_group.ecs.id]
  tags               = local.tags
}

module "task_nginx_app" {
  source = "./modules/task"

  vpc_id       = data.aws_vpc.main.id
  cluster_id   = aws_ecs_cluster.main.id
  service_name = "${local.name}-nginx-service"
  task_definition = {
    network_mode          = "awsvpc"
    cpu                   = 256
    container_definitions = file("./apps/nginx/task_definition.json")
  }

  aws_ecs_capacity_provider = {
    name = aws_ecs_capacity_provider.main.name
  }

  depends_on = [aws_autoscaling_group.ecs_sg]

  network = {
    subnets         = [var.subnet_1a, var.subnet_1b]
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer = {
    container_name = "nginx"
    container_port = 80
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = module.task_nginx_app.aws_lb_target_group_arn
  }
}


module "task_app_app" {
  source = "./modules/task"

  vpc_id       = data.aws_vpc.main.id
  cluster_id   = aws_ecs_cluster.main.id
  service_name = "${local.name}-app-service"
  task_definition = {
    network_mode          = "awsvpc"
    cpu                   = 256
    container_definitions = file("./apps/app/task_definition.json")
  }

  aws_ecs_capacity_provider = {
    name = aws_ecs_capacity_provider.main.name
  }

  depends_on = [aws_autoscaling_group.ecs_sg]

  network = {
    subnets         = [var.subnet_1a, var.subnet_1b]
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer = {
    container_name = "app"
    container_port = 80
  }
}

resource "aws_lb_listener_rule" "nginx_lb_rule" {
  listener_arn = aws_lb_listener.app.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = module.task_app_app.aws_lb_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/v2/data.json"]
    }
  }
}
