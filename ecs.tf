data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "ecs" {
  name = "${local.name}-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    self        = "false"
  }
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-template"
  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = var.instance_type
  # key_name               = "ec2ecsglog"
  vpc_security_group_ids = [aws_security_group.ecs.id]
  user_data = base64encode(<<-EOT
        #!/bin/bash
        echo ECS_CLUSTER=${local.name} >> /etc/ecs/ecs.config
      EOT
  )

  iam_instance_profile {
    name = "ecsInstanceRole"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }
}

resource "aws_autoscaling_group" "ecs_sg" {
  name             = "${local.name}-ecs-sg"
  desired_capacity = 3
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = [data.aws_subnet.subnet_1a.id, data.aws_subnet.subnet_1b.id]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Enviroment"
    value               = var.env
    propagate_at_launch = true
  }

  tag {
    key                 = "Repository"
    value               = "https://github.com/Tsugami/alura-ecs-com-terraform"
    propagate_at_launch = false
  }
}

resource "aws_ecs_cluster" "main" {
  name = local.name
  tags = local.tags
}

resource "aws_ecs_capacity_provider" "main" {
  name = "${local.name}-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_sg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 2
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ec2" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}



# resource "aws_ecs_task_definition" "nginx" {
#   family                = "${local.name}-nginx"
#   network_mode          = "awsvpc"
#   cpu                   = 256
#   container_definitions = file("./task-definitions/nginx.json")

#   runtime_platform {
#     operating_system_family = "LINUX"
#     cpu_architecture        = "X86_64"
#   }
# }

# resource "aws_ecs_service" "nginx" {
#   name            = "${local.name}-nginx"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.nginx.arn
#   desired_count   = 2


#   capacity_provider_strategy {
#     weight            = 100
#     capacity_provider = aws_ecs_capacity_provider.main.name
#   }

#   load_balancer {
#     container_name   = "nginx"
#     container_port   = 80
#     target_group_arn = aws_lb_target_group.ecs.arn
#   }

#   force_new_deployment = true
#   placement_constraints { // oq isso faz?
#     type = "distinctInstance"
#   }

#   network_configuration {
#     subnets         = [var.subnet_1a, var.subnet_1b]
#     security_groups = [aws_security_group.ecs.id]
#   }

#   triggers = {
#     redeployment = timestamp()
#   }

#   depends_on = [aws_autoscaling_group.ecs_sg]
# }


# resource "aws_lb_target_group" "ecs" {
#   name        = "${local.name}-tg"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = data.aws_vpc.main.id

#   health_check {
#     path = "/"
#   }
# }




# resource "aws_lb_listener" "ecs" {
#   load_balancer_arn = aws_lb.ecs.arn
#   port              = 80
#   protocol          = "HTTP"


#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs.arn
#   }
# }
