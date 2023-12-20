output "vpc_group" {
  value = {
    subnet_groups = { for k, vpc in module.vpc : k => vpc.vpc.subnet_groups }
    vpc_ids = { for k, vpc in module.vpc : k => vpc.vpc.vpc_id }
  }
}
