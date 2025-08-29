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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
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
# VPC Endpoints for ECR
# -----------------------

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [aws_security_group.ecs_sg.id]

  private_dns_enabled = true

  tags = {
    Name        = "${var.project}-ecr-api-endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [aws_security_group.ecs_sg.id]

  private_dns_enabled = true

  tags = {
    Name        = "${var.project}-ecr-dkr-endpoint"
    Environment = var.environment
  }
}
