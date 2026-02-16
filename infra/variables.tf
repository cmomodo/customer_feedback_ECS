variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type      = string
  sensitive = true
}

variable "db_identifier" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "identifier_username" {
  type      = string
  sensitive = true
}

variable "identifier_password" {
  type      = string
  sensitive = true
}

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

variable "primary_subnet_cidr" {
  description = "CIDR block for the primary public subnet"
  type        = string
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary public subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
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

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' for OIDC"
  type        = string
}
