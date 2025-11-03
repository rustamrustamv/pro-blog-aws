# terraform.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # Or your preferred region
}

# Create our secure private network
resource "aws_vpc" "blog_vpc" {
  cidr_block = "10.0.0.0/16"
  
  # ADD THESE TWO LINES
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "pro-blog-vpc"
  }
}

# Create two subnets for our database (for high availability)
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.blog_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "pro-blog-db-subnet-1"
  }
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.blog_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "pro-blog-db-subnet-2"
  }
}

resource "aws_internet_gateway" "blog_gw" {
  vpc_id = aws_vpc.blog_vpc.id
  tags = {
    Name = "pro-blog-igw"
  }
}

resource "aws_subnet" "app_subnet_1" {
  vpc_id                  = aws_vpc.blog_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # <-- This makes it a public subnet
  tags = {
    Name = "pro-blog-app-subnet-1"
  }
}

resource "aws_subnet" "app_subnet_2" {
  vpc_id                  = aws_vpc.blog_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true # <-- This makes it a public subnet
  tags = {
    Name = "pro-blog-app-subnet-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.blog_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # To the internet
    gateway_id = aws_internet_gateway.blog_gw.id
  }

  tags = {
    Name = "pro-blog-public-rt"
  }
}

# Associate our public subnets with this route table
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.app_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Create an AWS SSH Key Pair
resource "aws_key_pair" "blog_key" {
  key_name   = "blog-key-pro" # New name, just in case
  public_key = file("/home/ubuntu/.ssh/id_rsa.pub") # Use your WSL key
}