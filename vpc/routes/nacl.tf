resource "aws_network_acl" "network" {
  vpc_id = var.vpc_id

  subnet_ids = flatten([for k, s in var.subnet_groups : s.subnet_ids])

  dynamic ingress {
    for_each = var.default_nacl_inbound_rules

    content {
      from_port  = ingress.value["from_port"]
      to_port    = ingress.value["to_port"]
      rule_no    = ingress.value["rule_no"]
      action     = ingress.value["action"]
      cidr_block = ingress.value["cidr_block"]
      protocol   = ingress.value["protocol"]
    }
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = tomap({"Name" = var.vpc_name})
}
