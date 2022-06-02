locals {
  name = "lambda_http_checker"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs = ["${var.region}a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway = true
}
