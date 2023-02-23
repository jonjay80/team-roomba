terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.default_tags
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "DJRoomba-IGW"
  }
}

# Public subnet
resource "aws_subnet" "public" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
    Name = "DJRoomba-A"
  }
}

# public route table A
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
    "Name" = "DJRoomba-publicRT"
  }
}

# public route
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}

# public route table association
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
