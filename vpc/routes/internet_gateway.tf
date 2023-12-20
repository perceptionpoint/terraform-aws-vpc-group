locals {
  igw_route_table_ids = [for s in var.public_igw_subnet_groups : var.subnet_groups[s].route_table_id]
}

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
  count = length(var.public_igw_subnet_groups) > 0 ? 1 : 0
}

resource "aws_route" "public-subnet-to-igw" {
  count = length(local.igw_route_table_ids)

  route_table_id         = local.igw_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}
