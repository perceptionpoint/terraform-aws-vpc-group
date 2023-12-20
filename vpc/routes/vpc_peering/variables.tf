variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "route_tables" { type = list(string) }
variable "peer_vpc" {}
