resource "aws_vpc_peering_connection" "vpc_peering_requester" {
  for_each = var.vpc_group["internal_vpc_peerings"]

  vpc_id = module.vpc[each.value["requester"]["vpc_name"]].vpc.vpc_id
  peer_vpc_id = module.vpc[each.value["accepter"]["vpc_name"]].vpc.vpc_id
  auto_accept = false
  tags = {
    "Name": "${each.value["requester"]["vpc_name"]}-to-${each.value["accepter"]["vpc_name"]}"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_accepter" {
  for_each = var.vpc_group["internal_vpc_peerings"]

  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_requester[each.key].id
  auto_accept = true
  tags = {
    "Name": "${each.value["requester"]["vpc_name"]}-to-${each.value["accepter"]["vpc_name"]}"
  }
}

locals {
  accepter2requester_routes = merge([
    for k_ivp, v_ivp in var.vpc_group["internal_vpc_peerings"] : {
      for sgn in v_ivp["accepter"]["subnet_group_names"] :
          "${k_ivp}:${v_ivp["accepter"]["vpc_name"]}/${sgn}->${v_ivp["requester"]["vpc_name"]}" => {
            route_table_id = module.vpc[v_ivp["accepter"]["vpc_name"]].vpc["subnet_groups"][sgn].route_table_id
            destination_cidr_block = var.vpc_group["vpcs"][v_ivp["requester"]["vpc_name"]]["cidr_block"]
            vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_requester[k_ivp].id
          }
    }
  ]...)

  requester2accepter_routes = merge([
    for k_ivp, v_ivp in var.vpc_group["internal_vpc_peerings"] : {
      for sgn in v_ivp["requester"]["subnet_group_names"] :
          "${k_ivp}:${v_ivp["requester"]["vpc_name"]}/${sgn}->${v_ivp["accepter"]["vpc_name"]}" => {
            route_table_id = module.vpc[v_ivp["requester"]["vpc_name"]].vpc["subnet_groups"][sgn].route_table_id
            destination_cidr_block = var.vpc_group["vpcs"][v_ivp["accepter"]["vpc_name"]]["cidr_block"]
            vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_requester[k_ivp].id
          }
    }
  ]...)
}

resource "aws_route" "accepter2requester" {
  for_each = local.accepter2requester_routes

  route_table_id            = each.value["route_table_id"]
  destination_cidr_block    = each.value["destination_cidr_block"]
  vpc_peering_connection_id = each.value["vpc_peering_connection_id"]
}

resource "aws_route" "requester2accepter" {
  for_each = local.requester2accepter_routes

  route_table_id            = each.value["route_table_id"]
  destination_cidr_block    = each.value["destination_cidr_block"]
  vpc_peering_connection_id = each.value["vpc_peering_connection_id"]
}
