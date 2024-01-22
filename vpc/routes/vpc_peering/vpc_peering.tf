/**
 * Establishes a relationship resource between the "primary" and "peer" VPCs
 * requester's side of the connection
 */
resource "aws_vpc_peering_connection" "primary2peer" {
  peer_owner_id = var.peer_vpc["account_id"]
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc["vpc_id"]
  peer_region = var.peer_vpc["aws_region"]
  auto_accept   = false
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer-vpc" {
  provider = aws.peer_vpc
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2peer.id
  auto_accept = true
  count = (! (var.peer_vpc["external_accepter"]))? 1 : 0
}

/**
 * Route rule.
 *
 * Creates a new route rule on the "primary" VPC main route table. All requests
 * to the "secondary" VPC's IP range will be directed to the VPC peering
 * connection.
  */
resource "aws_route" "peer2primary" {
  provider = aws.peer_vpc
  route_table_id            = element(var.peer_vpc["rtbl_ids"], count.index)
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2peer.id
  count = (! var.peer_vpc["external_accepter"])? length(var.peer_vpc["rtbl_ids"]) : 0
}

/**
 * Route rule.
 *
 * Creates a new route rule on the "secondary" VPC main route table. All
 * requests to the "secondary" VPC's IP range will be directed to the VPC
 * peering connection.
 */
resource "aws_route" "primary2peer" {
  route_table_id            = element(var.route_tables, count.index)
  destination_cidr_block    = var.peer_vpc["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2peer.id
  count = length(var.route_tables)
}
