locals {
  name = "hawordpress"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.5.0/24", "10.0.6.0/24"]
  database_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  create_database_subnet_group = false
  enable_dns_hostnames = true
}
