output "vpc" {
  value = {
    subnet_groups = { for k, sg in module.subnet-group : k => sg.subnet_group }
    vpc_id = aws_vpc.vpc.id
  }
}
