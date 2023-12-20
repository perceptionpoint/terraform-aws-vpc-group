data "aws_region" "current" {}

resource "aws_subnet" "subnet" {
  vpc_id     = var.vpc_id
  map_public_ip_on_launch = var.subnet_group_properties["assign_public_ips"]
  cidr_block = cidrsubnet(var.vpc_cidr_block, var.subnet_group_properties["newbits"], var.subnet_group_properties["offset"] + count.index)

  availability_zone = "${data.aws_region.current.name}${var.subnet_group_properties["availability_zones"][count.index]}"

  tags = merge(tomap({"Name" = "${var.subnet_group_properties["subnet_group_name"]}-${data.aws_region.current.name}${var.subnet_group_properties["availability_zones"][count.index]}.${var.vpc_name}"}),
                  var.subnet_group_properties["extra_subnet_tags"])

  count = length(var.subnet_group_properties["availability_zones"])
}
