data "aws_region" "current" {}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = var.vpc_endpoints

  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  route_table_ids   = [for s in each.value : var.subnet_groups[s].route_table_id]
}
