data "aws_internet_gateway" "igw" {
  filter {
    name   = "tag:Name"
    values = ["Lab IGW"]
  }
  filter {
    name   = "attachment.vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

data "aws_route_table" "public" {
  filter {
    name   = "tag:Name"
    values = ["Public Route Table"]
  }
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}
