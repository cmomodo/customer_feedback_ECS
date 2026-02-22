#the cidr block for vpc holder
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

#primary subnet output
variable "primary_subnet" {
  description = "CIDR block for the primary public subnet"
  type        = string
}

#secondary subnet output
variable "secondary_public_subnet" {
  description = "CIDR block for the secondary public subnet"
  type        = string
}

#private subnet cidr holder
variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
}

#private subnet 2 holder
variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
}

#the azs we will use
variable "availability_zones" {
  description = "Availability zones to use (index 0 for primary, index 1 for secondary)"
  type        = list(string)
}

#we will create custom tags
variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
