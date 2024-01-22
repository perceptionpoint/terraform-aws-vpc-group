variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "route_tables" { type = list(string) }
variable "peer_vpc" { type = object({
                external_accepter = bool
                aws_region = string
                vpc_id = string
                rtbl_ids = optional(list(string), [])
                account_id = string
                cidr_block = string
            })}
