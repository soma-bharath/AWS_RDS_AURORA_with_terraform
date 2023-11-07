resource "aws_vpc" "prod-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "prod_vpc"
  }
}

resource "aws_subnet" "subnets" {
  count                   = length(var.public_availability_zones)
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.prod-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = var.public_availability_zones[count.index]
  tags = {
    Name = "Public-${var.subnet_names[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_availability_zones)
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.prod-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = var.private_availability_zones[count.index]
  tags = {
    Name = "Private-${var.subnet_names[count.index]}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod_internet_gateway"
  }
}

resource "aws_route_table" "prod-public-route" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "subnet-assoc" {
  count          = length(var.public_availability_zones)
  route_table_id = aws_route_table.prod-public-route.id
  subnet_id      = aws_subnet.subnets[count.index].id

}

resource "aws_route_table" "prod-private-route" {
  vpc_id = aws_vpc.prod-vpc.id
  #route {
  #  cidr_block = "0.0.0.0/0"
  # gateway_id = aws_internet_gateway.my_igw.id
  #}
  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private-subnet-assoc" {
  count          = length(var.private_availability_zones)
  route_table_id = aws_route_table.prod-private-route.id
  subnet_id      = aws_subnet.private_subnets[count.index].id

}
