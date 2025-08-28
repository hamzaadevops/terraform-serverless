# -----------------------
# CloudWatch Logs
# -----------------------
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 7
}

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
# ECS Service using Fargate Spot
# -----------------------
resource "aws_ecs_service" "services" {
  for_each        = var.services
  name            = each.key
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.tasks[each.key].arn
  desired_count   = each.value.desired_count
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
    target_group_arn = aws_lb_target_group.tg[each.key].arn
    container_name   = each.value.container_name
    container_port   = each.value.port
  }

  tags = {
    Name        = each.key
    Environment = var.environment
    Project     = var.project
  }
}
