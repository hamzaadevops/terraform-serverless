environment = "demo"
project = "ecs-fargate-demo"
security_group_demo="ecs-fargate-sg"
service_name="demo-service"
container_port=3000
container_name="app"
public_ip=true
task_def="demo-task"
image_name="589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/test:latest"
cluster_name="demo-fargate-cluster"
aws_region="ap-southeast-1"

services = {
  "ashtra" = {
    cpu            = "1024"
    memory         = "4096"
    container_name = "app"
    image          = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/test:latest"
    port           = 3000
    path           = "/ashtra/*"
    desired_count  = 1
  }
  "nginx" = {
    cpu            = "1024"
    memory         = "4096"
    container_name = "app"
    image          = "nginx:latest"
    port           = 3000
    path           = "/nginx/*"
    desired_count  = 1
  }
  "httpd" = {
    cpu            = "1024"
    memory         = "4096"
    container_name = "app"
    image          = "httpd:latest"
    port           = 3000
    path           = "/httpd/*"
    desired_count  = 1
  }
  "dash" = {
    cpu            = "4096"
    memory         = "16384"
    container_name = "app"
    image          = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/dash:v1"
    port           = 3000
    path           = "/dash/*"
    desired_count  = 1
  }
}
