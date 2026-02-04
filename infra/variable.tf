variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "base_url" {
  description = "The base URL for the application"
  type        = string
}

variable "environment" {
  description = "Extra environment variables for the app"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

#primary subnet
variable "primary_subnet" {
  description = "CIDR block for the VPC"
  type        = string
}

#secondary public subnet
variable "secondary_public_subnet" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
