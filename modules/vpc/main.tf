provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
    Name = var.app_name
    Env  = var.env
  }
}

# Public subnets #######################################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = element(var.public_subnets, count.index )
  availability_zone       = element(var.availability_zones, count.index )
  map_public_ip_on_launch = true

  tags = {
    Name = "${lower(var.app_name)}-public-subnet-${count.index}"
    Env  = var.env
  }
}


resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

# Private subnets ###################################################
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index )
  availability_zone = element(var.availability_zones, count.index )

  tags = {
    Name = "${lower(var.app_name)}-private-subnet-${count.index}"
    Env  = var.env
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${lower(var.app_name)}private-route-table"
    Env  = var.env
  }
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "nat_eip" {
    count      = length(var.public_subnets)
    depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_nat_gateway" "nat_gw" {
    count         = length(var.public_subnets)
    subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
    allocation_id = element(aws_eip.nat_eip.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
    count  = length(var.availability_zones)
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
    }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
    count  = length(var.availability_zones)
    subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
    route_table_id = element(aws_route_table.private.*.id, count.index)
}