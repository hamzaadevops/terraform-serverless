provider "aws" {
  region  = "ap-southeast-1"
  profile = "pfs"
}

variable "environment" {
  default = "demo"
}

variable "project" {
  default = "ecs-fargate-demo"
}

variable "security_group_demo" {
  default = "ecs-fargate-sg"
}

variable "service_name" {
  default = "demo-service"
}

variable "container_name" {
  default = "demo-app"
}

variable "container_port" {
  default = 80
}

variable "public_ip" {
  default = true
}

variable "task_def"{
  default = "demo-task"
}

variable "image_name"{
  default = "589736534170.dkr.ecr.ap-southeast-1.amazonaws.com/hamza/test:latest"
}

variable "cluster_name" {
  default = "demo-fargate-cluster"
}