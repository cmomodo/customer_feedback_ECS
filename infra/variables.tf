#database username
variable "db_username" {
  type      = string
  sensitive = true
}

#databse password
variable "db_password" {
  type      = string
  sensitive = true
}

#database name
variable "db_name" {
  type      = string
  sensitive = true
}

#database identifer
variable "db_identifier" {
  type      = string
  sensitive = true
}

#the jwt secret
variable "jwt_secret" {
  type      = string
  sensitive = true
}

#username for identifer
variable "identifier_username" {
  type      = string
  sensitive = true
}

#identifier passwowrd
variable "identifier_password" {
  type      = string
  sensitive = true
}

#aws region
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

#the container port that should be used
variable "container_port" {
  description = "Container port for ECS service and ALB target group"
  type        = number
  default     = 3000
}

#environment variable
variable "environment" {
  description = "Extra environment variables for the app"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

#github repo oidc should target
variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' for OIDC"
  type        = string
}
