module "task_nginx" {
  source = "./modules/task"

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
}
