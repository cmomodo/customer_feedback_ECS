variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "primary_subnet" {
  description = "CIDR block for the primary public subnet"
  type        = string
}

variable "secondary_public_subnet" {
  description = "CIDR block for the secondary public subnet"
  type        = string
  default     = "192.168.1.128/25"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
  default     = "192.168.1.64/26"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "192.168.1.192/26"
}

variable "availability_zones" {
  description = "Availability zones to use (index 0 for primary, index 1 for secondary)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
