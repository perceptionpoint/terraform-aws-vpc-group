module "vpc" {
  source = "./vpc"
  for_each = var.vpc_group["vpcs"]

  vpc_properties = each.value
}