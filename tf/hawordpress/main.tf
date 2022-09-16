terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.14.0"
    }
  }
}

variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}


provider "aws" {
  region = var.region
  profile = "edu"
}
