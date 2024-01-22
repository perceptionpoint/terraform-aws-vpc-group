locals {
  vpc_modules = { for k, vpc in module.vpc : k => vpc.vpc }
  should_generate_external_vpc_peerings = length([ for v in var.vpc_group["vpcs"] : 1 if length(keys(v.external_vpc_peerings)) > 0 ])
}

data "aws_region" "current" {}

resource "local_file" "providers_tf" {
  content  = templatefile("${path.module}/providers.tmpl", { var_vpc_group = var.vpc_group, current_aws_region = data.aws_region.current.name })
  filename = "${path.root}/generated_external_vpc_peerings/providers.tf"

  count = local.should_generate_external_vpc_peerings > 0 ? 1 : 0
}

resource "local_file" "external_vpc_peerings_tf" {
  content  = templatefile("${path.module}/external_vpc_peerings.tmpl", { var_vpc_group = var.vpc_group, vpc_modules = local.vpc_modules, module_path = "${path.module}" })
  filename = "${path.root}/generated_external_vpc_peerings/external_vpc_peerings.tf"

  count = local.should_generate_external_vpc_peerings > 0 ? 1 : 0
}

resource "local_file" "main_external_vpc_peerings_tf" {
  content  = "module \"external_vpc_peerings\" { source = \"./generated_external_vpc_peerings\" }\n"
  filename = "${path.root}/main_external_vpc_peerings.tf"

  count = local.should_generate_external_vpc_peerings > 0 ? 1 : 0
}
