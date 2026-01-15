data "aws_region" "current" {}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = var.vpc_endpoints
  depends_on = [aws_security_group.vpc_endpoint_sg]

  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type = each.value.vpc_endpoint_type

  route_table_ids  = each.value.vpc_endpoint_type == "Gateway" ? [for s in each.value.subnet_groups : var.subnet_groups[s].route_table_id] : null
  
  subnet_ids = contains(["Interface", "GatewayLoadBalancer"], each.value.vpc_endpoint_type) ? var.subnet_groups[each.value.subnet_groups[0]].subnet_ids : null
  
  private_dns_enabled = each.value.vpc_endpoint_type == "Interface" ? true : null
  security_group_ids = each.value.vpc_endpoint_type == "Interface" ? [aws_security_group.vpc_endpoint_sg[each.key].id] : null
}


resource "aws_security_group" "vpc_endpoint_sg" {
  for_each = {
    for k, v in var.vpc_endpoints : k => v
    if v.vpc_endpoint_type == "Interface"
  }

  name        = "${each.key}-vpc_endpoint_sg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_properties
    content {
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["protocol"]
      cidr_blocks      = [var.vpc_cidr_block]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}
