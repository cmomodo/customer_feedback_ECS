terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0"
    }
  }

  # Partial backend config. CI injects bucket/key/region during `terraform init`.
  backend "s3" {
    encrypt      = true
    use_lockfile = true
    key          = "global/s3/bootstrapv1.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}
