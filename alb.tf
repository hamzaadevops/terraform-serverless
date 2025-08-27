# -----------------------
# ALB (Application Load Balancer)
# -----------------------
resource "aws_lb" "ecs_alb" {
  name               = "ecs-demo-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.ecs_sg.id]

  tags = {
    Name        = "ecs-demo-alb"
    Environment = var.environment
    Project     = var.project
    CostCenter  = "demo-stage"
  }
}

# -----------------------
# Target Group
# -----------------------
resource "aws_lb_target_group" "tg" {
  for_each    = var.services
  name        = "tg-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  
  tags = {
    Name        = "ecs-demo-tg"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------
# Listener
# -----------------------
resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = {
    Name        = "ecs-demo-listener"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------
# Listener Rules
# -----------------------
locals {
  service_list = keys(var.services)
}

resource "aws_lb_listener_rule" "rules" {
  for_each     = var.services
  listener_arn = aws_lb_listener.ecs_listener.arn

  # Generate stable priorities: 100, 101, 102, ...
  priority     = 100 + index(local.service_list, each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }
  tags = {
    Name        = "ecs-demo-listener-rules"
    Environment = var.environment
    Project     = var.project
  }
}
