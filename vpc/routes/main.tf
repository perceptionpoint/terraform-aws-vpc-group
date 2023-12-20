module "nat" {
  source = "./nat"
  for_each = var.nat_gateways

  public_subnet_ids = var.subnet_groups[each.value["public_subnet_group"]].subnet_ids
  private_subnet_rtbl_ids = [for s in each.value["private_subnet_groups"] : var.subnet_groups[s].route_table_id]
}

resource "aws_vpn_gateway" "vpn-gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-vpn-gw"
  }

  count = (length(var.vpn_connections) > 0)? 1 : 0
}

module "vpn" {
  source = "./vpn"
  for_each = var.vpn_connections

  name = "${each.key}-${var.vpc_name}"
  vpn_ip = each.value.cgw_ip
  attach_vpn_rtbl_ids = each.value.attach_subnet_groups
  vpn_gw_id = aws_vpn_gateway.vpn-gw[0].id
}

module "route53_resolver" {
  source  = "./route53_resolver"

  vpc_id = var.vpc_id
  subnet_ids = flatten([for s in var.route53_resolver_settings["attach_subnet_groups"] : var.subnet_groups[s].subnet_ids])
  rules = var.route53_resolver_settings["forwarder_rules"]
  enable_inbound_resolver = var.route53_resolver_settings["enable_inbound_resolver"]

  count = var.route53_resolver_settings == null ? 0 : 1
}
