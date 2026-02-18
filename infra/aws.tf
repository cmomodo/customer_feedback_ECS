terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
