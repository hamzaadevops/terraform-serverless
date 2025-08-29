provider "aws" {
  region  = var.aws_region
  profile = "pfs"
}

variable "aws_region" {}

variable "environment" {}

variable "project" {}

variable "security_group_demo" {}

variable "service_name" {}

variable "container_name" {}

variable "container_port" {}

variable "public_ip" {}

variable "task_def"{}

variable "image_name"{}

variable "cluster_name" {}

variable "route53_zone_id" {}

variable "domain_name" {}

variable "services" {
  type = map(object({
    cpu             = string
    memory          = string
    container_name  = string
    image           = string
    port            = number
    path            = string
    domain          = string
    desired_count   = number
  }))
}

