locals {
  name = "elk"
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   version = "~> 3.0"

#   name = "${local.name}-vpc"
#   cidr = "10.0.0.0/16"

#   azs             = ["${var.region}a", "${var.region}b"]
#   private_subnets = ["10.0.15.0/24", "10.0.16.0/24"]
#   public_subnets  = ["10.0.17.0/24", "10.0.18.0/24"]

#   enable_dns_hostnames = true
#   enable_nat_gateway = true
# }

# VPC Setup
resource "aws_vpc" "hawordpress" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  
}

# VPC Subnets
resource "aws_subnet" "hawordpress-public-eu-central-1a" {
  vpc_id                  = aws_vpc.hawordpress.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.region}a"
  tags = {
    Name = "hawordpress-public-eu-cental-1a"
  }
}
resource "aws_subnet" "hawordpress-public-eu-central-1b" {
  vpc_id                  = aws_vpc.hawordpress.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.region}b"
  tags = {
    Name = "hawordpress-public-eu-cental-1b"
  }
}

resource "aws_subnet" "hawordpress-private-eu-central-1a" {
  vpc_id                  = aws_vpc.hawordpress.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}a"
  tags = {
    Name = "hawordpress-private-eu-cental-1a"
  }
}

resource "aws_subnet" "hawordpress-private-eu-central-1b" {
  vpc_id                  = aws_vpc.hawordpress.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}b"
  tags = {
    Name = "hawordpress-private-eu-cental-1b"
  }
}


# Internet GW
resource "aws_internet_gateway" "hawordpress-gw" {
  vpc_id = aws_vpc.hawordpress.id
  tags = {
    Name = "hawordpress-igw"
  }
}

# Route Table for Public
resource "aws_route_table" "hawordpress-public" {
  vpc_id = aws_vpc.hawordpress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hawordpress-gw.id
  }
  tags = {
    Name = "hawordpress-public-rt"
  }
}

# Route Associations public
resource "aws_route_table_association" "hawordpress-public-1-a" {
  subnet_id      = aws_subnet.hawordpress-public-eu-central-1a.id
  route_table_id = aws_route_table.hawordpress-public.id
}
resource "aws_route_table_association" "main-public-2-a" {
  subnet_id      = aws_subnet.hawordpress-public-eu-central-1b.id
  route_table_id = aws_route_table.hawordpress-public.id
}

# NAT GW
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.hawordpress-public-eu-central-1a.id
  depends_on    = [aws_internet_gateway.hawordpress-gw]
  tags = {
    Name = "hawordpress-nat-gw"
  }
}

# Route Table setup for Private through NAT
resource "aws_route_table" "hawordpress-private" {
  vpc_id = aws_vpc.hawordpress.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
    # gateway_id = aws_internet_gateway.hawordpress-gw.id  
  }

  tags = {
    Name = "main-private-rt"
  }
}

# Route Associations private
resource "aws_route_table_association" "hawordpress-private-1a" {
  subnet_id      = aws_subnet.hawordpress-private-eu-central-1a.id
  route_table_id = aws_route_table.hawordpress-private.id
}
resource "aws_route_table_association" "hawordpress-private-1b" {
  subnet_id      = aws_subnet.hawordpress-private-eu-central-1b.id
  route_table_id = aws_route_table.hawordpress-private.id
}