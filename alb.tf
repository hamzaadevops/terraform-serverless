# -----------------------
# ACM (AWS Certificate Manager)
# -----------------------
resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "alb-cert"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------
# Route53 Record
# -----------------------
resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "alb_cert_validation" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}

resource "aws_route53_record" "alb_alias" {
  for_each = var.services

  zone_id  = var.route53_zone_id
  name     = each.value.domain      # e.g., "app.example.com"
  type     = "A"

  alias {
    name                   = aws_lb.ecs_alb.dns_name
    zone_id                = aws_lb.ecs_alb.zone_id
    evaluate_target_health = true
  }
}

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
# Listener HTTP
# -----------------------
resource "aws_lb_listener" "ecs_http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
   type = "redirect"
   redirect {
     port        = "443"
    protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
 }

  tags = {
    Name        = "ecs-demo-listener"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------
# Listener HTTPS
# -----------------------
resource "aws_lb_listener" "ecs_https_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.alb_cert_validation.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = {
    Name        = "ecs-demo-https-listener"
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
  listener_arn = aws_lb_listener.ecs_https_listener.arn

  # Generate stable priorities: 100, 101, 102, ...
  priority     = 100 + index(local.service_list, each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    host_header {
      values = [each.value.domain]
    }
    # path_pattern {
    #   values = [each.value.path]
    # }
  }

  tags = {
    Name        = "ecs-demo-listener-rules"
    Environment = var.environment
    Project     = var.project
  }
}
