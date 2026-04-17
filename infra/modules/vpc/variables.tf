#the cidr block for vpc holder
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

#public subnets holder
variable "public_subnets" {
  description = "Public subnets"
  type        = map(object({ cidr = string }))
  default     = {
    public-a = { cidr = "10.20.1.0/24" }
    public-b = { cidr = "10.20.2.0/24" }
  }
} 

#availability zones for public subnet
variable "availability_zones" {
  description = "Availability zones for public subnet"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "Private subnets"
  type        = map(object({ cidr = string }))
  default     = {
    private-a = { cidr = "10.20.3.0/24" }
    private-b = { cidr = "10.20.4.0/24" }
  }
}
