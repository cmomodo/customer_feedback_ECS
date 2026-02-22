variable "aws_region" {
  description = "AWS region for the Terraform state bucket"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name used by the infra Terraform backend"
  type        = string
  default     = "my-27-state-bucket"
}

variable "tags" {
  description = "Tags applied to bootstrap resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "coderco-ecs-v1"
    Stack     = "bootstrap"
  }
}
