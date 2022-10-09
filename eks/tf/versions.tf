terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.31.0"
    }
  }
  backend "s3" {
    bucket = "coe-internship-etc-files"
    key = "backends/eks-backend"
    region = "eu-central-1"
  }
}

provider "aws" {
  # Configuration options
}