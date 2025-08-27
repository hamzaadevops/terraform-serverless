# -----------------------
# Output ALB DNS Name
# -----------------------
output "ecs_service_url" {
  value = "http://${aws_lb.ecs_alb.dns_name}"
}
