resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = var.public_subnet_ids[0] # TODO: consider attaching each subnet to its own NAT gateway
  tags = {
    product = "mantis"
    sub-product = "nat-gateway"
  }
}

resource "aws_route" "private-subnet-to-nat" {
  count = length(var.private_subnet_rtbl_ids)

  route_table_id         = var.private_subnet_rtbl_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
