resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_properties["cidr_block"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = merge(tomap({"Name" = var.vpc_properties["vpc_name"]}),
               var.vpc_properties["extra_vpc_tags"]
          )
}

resource "aws_default_security_group" "vpc-default" {
  vpc_id = aws_vpc.vpc.id
}

module "subnet-group" {
  source = "./subnet_group"
  subnet_group_name = each.key
  vpc_id = aws_vpc.vpc.id
  vpc_cidr_block = aws_vpc.vpc.cidr_block
  vpc_name = var.vpc_properties["vpc_name"]
  subnet_group_properties = each.value

  for_each = var.vpc_properties["subnet_groups"]
}

module "routes" {
  source  = "./routes"

  vpc_id = aws_vpc.vpc.id
  vpc_name = var.vpc_properties["vpc_name"]
  vpc_cidr_block = aws_vpc.vpc.cidr_block
  subnet_groups = { for k, sg in module.subnet-group : k => sg.subnet_group }
  nat_gateways = var.vpc_properties["nat_gateways"]
  vpn_connections = var.vpc_properties["vpn_connections"]
  public_igw_subnet_groups = var.vpc_properties["public_igw_subnet_groups"]
  default_nacl_inbound_rules = var.vpc_properties["default_nacl_inbound_rules"]
  vpc_endpoints = var.vpc_properties["vpc_endpoints"]
  route53_resolver_settings = var.vpc_properties["route53_resolver_settings"]
}
