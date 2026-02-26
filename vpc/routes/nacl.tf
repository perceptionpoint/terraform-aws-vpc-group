locals {
  ports = {
    ssh = 22
    rdp = 3389
  }
  combinations = setproduct(keys(var.nacl_connect_allowed_cidrs), keys(local.ports))
  nacl_connect_allow = {
    for idx, combo in local.combinations : "${combo[0]}_${combo[1]}" => {
      from_port = local.ports[combo[1]]
      to_port = local.ports[combo[1]]
      rule_no = 100 + idx
      action = "allow"
      cidr_block = var.nacl_connect_allowed_cidrs[combo[0]]
      protocol = "tcp"
    }
  }
  nacl_connect_deny = {
    for idx, port in keys(local.ports) : "deny_${port}" => {
      from_port = local.ports[port]
      to_port = local.ports[port]
      rule_no = 100 + length(local.combinations) + idx
      action = "deny"
      cidr_block = "0.0.0.0/0"
      protocol = "tcp"
    }
  }
  nacl_allow_all = {
    allow_all = {
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port= 0
      to_port = 0
      protocol = "all"
      rule_no = 100 + length(local.combinations) + length(local.ports)
    }
  }
  nacl_ingress_rules = merge(local.nacl_connect_allow, local.nacl_connect_deny, local.nacl_allow_all)
}

resource "aws_network_acl" "network" {
  vpc_id = var.vpc_id

  subnet_ids = flatten([for k, s in var.subnet_groups : s.subnet_ids])

  dynamic ingress {
    for_each = local.nacl_ingress_rules

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
