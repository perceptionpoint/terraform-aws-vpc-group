output "vpc_group" {
  value = {
    subnet_groups = { for k, vpc in module.vpc : k => vpc.vpc.subnet_groups }
    vpc_ids = { for k, vpc in module.vpc : k => vpc.vpc.vpc_id }
    internal_vpc_peerings = merge(
      [ for k, v in var.vpc_group["internal_vpc_peerings"] :
         {
           k: aws_vpc_peering_connection.vpc_peering_requester[k].id,
           v: aws_vpc_peering_connection.vpc_peering_requester[k].id
         }
      ]... # three dots (...) turns lists/tuples into multiple arguments
    )
  }
}
