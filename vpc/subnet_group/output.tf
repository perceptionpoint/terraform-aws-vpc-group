output "subnet_group" {
  value = {
    subnet_ids = aws_subnet.subnet.*.id
    route_table_id = length(aws_route_table.route_table) > 0 ? aws_route_table.route_table[0].id : aws_route_table.route_table_ignore_routes[0].id
  }
}
