data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [ data.aws_vpc.default.id ]
  }
}

// Subnet used for outbound traffic from private subnet
resource "aws_subnet" "public_subnet" {
  vpc_id      = data.aws_vpc.default.id
  cidr_block  = var.public_subnet_cidr_block
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_subnet_routes" {
  vpc_id      = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_routes.id
}

resource "aws_eip" "nat" {
  depends_on  = [ data.aws_internet_gateway.default ]
  vpc         = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

// Subnet used for connecting to Redshift and S3 by Glue and Loader Lambda
resource "aws_subnet" "private_redshift_subnet_shared_with_lambdas_and_glue" {
  cidr_block        = var.redshift_subnet_cidr_block
  availability_zone = "${var.aws_region}a"
  vpc_id            = data.aws_vpc.default.id

  tags = {
    Name = "redshift-private-subnet"
  }
}

// Allow outbound traffic to the Internet via NAT Gateway on the public subnet
resource "aws_route_table" "private_redshift_subnet_routes" {
  vpc_id      = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.private_redshift_subnet_shared_with_lambdas_and_glue.id
  route_table_id = aws_route_table.private_redshift_subnet_routes.id
}

// Setup VPC Endpoint to S3 required by Glue
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = [ aws_route_table.private_redshift_subnet_routes.id ]
  vpc_endpoint_type = "Gateway"
}
