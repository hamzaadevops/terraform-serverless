# -----------------------
# ECS Cluster
# -----------------------
resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.cluster_name

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project
    CostCenter  = "demo-stage"
  }
}

# -----------------------
# IAM Roles
# -----------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoleDemo"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "ecs-task-execution-role"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------
# ECS Task Definition
# -----------------------
resource "aws_ecs_task_definition" "demo_task" {
  family                   = var.task_def
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"   # 4 vCPU
  memory                   = "16384"  # 16 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.image_name
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
  }])

  tags = {
    Name        = var.task_def
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------
# VPC & Networking
# -----------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = var.security_group_demo
  description = "Allow HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.security_group_demo
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------
# ECS Service using Fargate Spot
# -----------------------
resource "aws_ecs_service" "demo_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.demo_task.arn
  desired_count   = 1
  # launch_type     = "FARGATE"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = var.public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_service1.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = {
    Name        = var.service_name
    Environment = var.environment
    Project     = var.project
  }
}
