resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  tags = tomap({"Name" = "${var.subnet_group_properties["subnet_group_name"]}-route_table.${var.vpc_name}"})

  count = var.subnet_group_properties["ignore_routes_changes"] ? 0 : 1
}

resource "aws_route_table" "route_table_ignore_routes" {
  vpc_id = var.vpc_id
  tags = tomap({"Name" = "${var.subnet_group_properties["subnet_group_name"]}-route_table.${var.vpc_name}"})

  lifecycle {
    ignore_changes = [
      route
    ]
  }

  count = var.subnet_group_properties["ignore_routes_changes"] ? 1 : 0
}

resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = var.subnet_group_properties["ignore_routes_changes"] ? aws_route_table.route_table_ignore_routes[0].id : aws_route_table.route_table[0].id

  count = length(var.subnet_group_properties["availability_zones"])
}
