# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Lab VPC"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Private Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Lab IGW"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Public Route to Internet
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group - HTTP only (no egress rules)
resource "aws_security_group" "app_sg" {
  name        = "App-SG"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow web access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "App-SG"
  }
  lifecycle {
    ignore_changes = [egress]
  }

}


# EC2 Instance
resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = true

  # User data to bootstrap Ansible pull
  user_data = <<-EOF
              #!/bin/bash
              # Install Apache Web Server and PHP
              dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
              dnf install -y mariadb105-server
              # Download Lab files
              wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACACAD-3-113230/06-lab-mod7-guided-VPC/s3/scripts/al2023-inventory-app.zip -O inventory-app.zip
              unzip inventory-app.zip -d /var/www/html/
              # Download and install the AWS SDK for PHP
              wget https://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
              unzip aws.zip -d /var/www/html
              # Turn on web server
              systemctl enable httpd
              systemctl start httpd
              EOF
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "App Server"
  }
}
