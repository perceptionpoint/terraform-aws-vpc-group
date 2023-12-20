output "subnet_group" {
  value = {
    subnet_ids = aws_subnet.subnet.*.id
    route_table_id = aws_route_table.route_table.id
  }
}
