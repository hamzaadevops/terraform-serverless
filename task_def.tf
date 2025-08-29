# -----------------------
# ECS Task Definition
# -----------------------
resource "aws_ecs_task_definition" "tasks" {
  for_each                 = var.services
  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = each.value.container_name
    image     = each.value.image
    essential = true
    portMappings = [{
      containerPort = each.value.port
      hostPort      = each.value.port
      protocol      = "tcp"
    }]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = each.value.container_name
        }
      }
    }
  ])

  tags = {
    Name        = each.key
    Environment = var.environment
    Project     = var.project
  }
}

