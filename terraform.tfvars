environment = "demo"
project = "ecs-fargate-demo"
security_group_demo="ecs-fargate-sg"
service_name="demo-service"
container_port=3000
container_name="app"
public_ip=false
task_def="demo-task"
image_name="589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/test:latest"
cluster_name="demo-fargate-cluster"
aws_region="ap-southeast-1"
route53_zone_id="Z02745981J3FQC8Y0Z4P7"
domain_name="*.less.awssolutionsprovider.com"

services = {
  "ashtra" = {
    cpu            = "1024"
    memory         = "4096"
    container_name = "app"
    image          = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/test:latest"
    port           = 80
    path           = "/ashtra*"
    domain         = "ashtra.less.awssolutionsprovider.com"
    desired_count  = 1
  }
  "nginx" = {
    cpu            = "1024"
    memory         = "4096"
    container_name = "app"
    image          = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/nginx:latest"
    port           = 80
    path           = "/nginx*"
    domain         = "nginx.less.awssolutionsprovider.com"
    desired_count  = 1
  }
  "httpd" = {
    cpu            = "1024"
    memory         = "4096"
    container_name = "app"
    image          = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/httpd:latest"
    port           = 80
    path           = "/httpd*"
    domain         = "httpd.less.awssolutionsprovider.com"
    desired_count  = 1
  }
  "dash" = {
    cpu            = "4096"
    memory         = "16384"
    container_name = "app"
    image          = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/dash:v1"
    port           = 3000
    path           = "/dash*"
    domain         = "dash.less.awssolutionsprovider.com"
    desired_count  = 1
  }
}
