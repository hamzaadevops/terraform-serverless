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
    },
{
  name      = "${each.value.container_name}-proxy"
  image     = "nginx:alpine"
  essential = true
  portMappings = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = "${each.key}-proxy"
    }
  }

  entryPoint = ["/bin/sh", "-c"]

  command = [
    <<EOT
      cat > /etc/nginx/conf.d/default.conf <<EOF
      server {
        listen 80;
        location ${each.value.path} {
          rewrite ^${each.value.path}(/.*)$ $1 break;
          proxy_pass http://127.0.0.1:${each.value.port};
        }
      }
      EOF
      exec nginx -g 'daemon off;'
    EOT
    ]
    }
  ])

  tags = {
    Name        = each.key
    Environment = var.environment
    Project     = var.project
  }
}

