resource "aws_vpc_peering_connection" "vpc_peering_requester" {
  for_each = var.vpc_group["internal_vpc_peerings"]

  vpc_id = module.vpc[each.key].vpc.vpc_id
  peer_vpc_id = module.vpc[each.value].vpc.vpc_id
  auto_accept = false
  tags = {
    "Name": "${var.vpc_group["vpcs"][each.key]["vpc_name"]}-to-${var.vpc_group["vpcs"][each.value]["vpc_name"]}"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_accepter" {
  for_each = var.vpc_group["internal_vpc_peerings"]

  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_requester[each.key].id
  auto_accept = true
  tags = {
    "Name": "${var.vpc_group["vpcs"][each.key]["vpc_name"]}-to-${var.vpc_group["vpcs"][each.value]["vpc_name"]}"
  }
}
