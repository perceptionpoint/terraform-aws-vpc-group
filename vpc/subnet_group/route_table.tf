resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  tags = tomap({"Name" = "${var.subnet_group_properties["subnet_group_name"]}-route_table.${var.vpc_name}"})
}

resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = element(aws_route_table.route_table.*.id, count.index)

  count = length(var.subnet_group_properties["availability_zones"])
}
