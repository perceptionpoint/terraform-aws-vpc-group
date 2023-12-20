resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "route53-resolver-inbound"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.route53-resolver-sg.id]
  dynamic "ip_address" {
    for_each = var.subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  count = var.enable_inbound_resolver == true ? 1 : 0
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name      = "route53-resolver-outbound"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.route53-resolver-sg.id]
  dynamic "ip_address" {
    for_each = var.subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }
  count = var.rules!=null ? 1 : 0
}

resource "aws_route53_resolver_rule" "rules" {
  domain_name          = var.rules[count.index].domain
  name                 = var.rules[count.index].domain
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.0.id
  dynamic "target_ip" {
    for_each = toset(var.rules[count.index].forwarding_ips)
    iterator = item
    content{
      ip = item.key
    }
  }
  count = var.rules!=null ? length(var.rules) : 0
}
