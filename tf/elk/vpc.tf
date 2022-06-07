locals {
  name = "elk"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.15.0/24", "10.0.16.0/24"]
  public_subnets  = ["10.0.17.0/24", "10.0.18.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway = true
}

# resource "aws_vpc" "elastic_vpc"{
#   cidr_block = cidrsubnet("172.20.0.0/16",0,0)
#   tags={
#     Name="elastic_vpc"
#   }
# }

# resource "aws_internet_gateway" "elastic_internet_gateway" {
#   vpc_id = aws_vpc.elastic_vpc.id
#   tags = {
#     Name = "elastic_igw"
#   }
# }

# resource "aws_route_table" "elastic_rt" {
#   vpc_id = aws_vpc.elastic_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.elastic_internet_gateway.id
#   }
#   tags = {
#     Name = "elastic_rt"
#   }
# }

# resource "aws_main_route_table_association" "elastic_rt_main" {
#   vpc_id         = aws_vpc.elastic_vpc.id
#   route_table_id = aws_route_table.elastic_rt.id
# }

# resource "aws_subnet" "elastic_subnet"{
#   for_each = {eu-central-1a=cidrsubnet("172.20.0.0/16",8,10),eu-central-1b=cidrsubnet("172.20.0.0/16",8,20),eu-central-1c=cidrsubnet("172.20.0.0/16",8,30)}
#   vpc_id = aws_vpc.elastic_vpc.id
#   availability_zone = each.key
#   cidr_block = each.value
#   tags={
#     Name="elastic_subnet_${each.key}"
#   }
# }

# variable "az_name" {
#   type    = list(string)
#   default = ["eu-central-1a","eu-central-1b","eu-central-1c"]
# }
