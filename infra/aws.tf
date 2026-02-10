terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {


  default_tags {
    tags = {
      Environment = "staging"
    }
  }
}
