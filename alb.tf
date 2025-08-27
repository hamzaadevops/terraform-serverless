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
resource "aws_lb_target_group" "tg_service1" {
  name        = "tg-service1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  
  tags = {
    Name        = "ecs-demo-tg"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb_target_group" "tg_service2" {
  name        = "tg-service2"
  port        = 80
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
resource "aws_lb_listener_rule" "service1_rule" {
  listener_arn = aws_lb_listener.ecs_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_service1.arn
  }

  condition {
    path_pattern {
      values = ["/service1/*"]
    }
  }
  tags = {
    Name        = "ecs-demo-listener-rule1"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb_listener_rule" "service2_rule" {
  listener_arn = aws_lb_listener.ecs_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_service2.arn
  }

  condition {
    path_pattern {
      values = ["/service2/*"]
    }
  }
  tags = {
    Name        = "ecs-demo-listener-rule2"
    Environment = var.environment
    Project     = var.project
  }
}
