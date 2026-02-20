variable "security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the ALB target group"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "container_port" {
  description = "Container port for the target group"
  type        = number
  default     = 3000
}
