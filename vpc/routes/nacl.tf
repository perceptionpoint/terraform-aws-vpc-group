resource "aws_network_acl" "network" {
  vpc_id = var.vpc_id

  subnet_ids = flatten([for s in var.nacl_subnet_groups : var.subnet_groups[s].subnet_ids]) # flatten([for s in var.subnet_groups : s.subnet_ids])

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
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
