terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.19.0"
    }
  }
}

# Provider block
provider "aws" {
  region = "us-east-1" #var.region
}
#backend
terraform {
  backend "s3" {
  }
}