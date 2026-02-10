variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "base_url" {
  description = "The base URL for the application"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route53/ACM"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "container_port" {
  description = "Container port for ECS service and ALB target group"
  type        = number
  default     = 3000
}

variable "environment" {
  description = "Extra environment variables for the app"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
