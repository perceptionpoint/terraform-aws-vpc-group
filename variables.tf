variable "vpc_group" { type = object({
        vpcs = map(object({
            vpc_name = string
            cidr_block = string
            extra_vpc_tags = optional(map(string), null)
            subnet_groups = map(object({
                subnet_group_name = string
                availability_zones = list(string)
                newbits = number
                offset = number
                assign_public_ips = bool
                extra_subnet_tags = optional(map(string), {})
            }))
            public_igw_subnet_groups = list(string)
            nacl_subnet_groups = optional(list(string), [])
            vpc_endpoints = optional(map(list(string)), {})
            external_vpc_peerings = map(object({
                external_accepter = bool
                aws_region = string
                vpc_id = string
                rtbl_ids = optional(list(string), [])
                account_id = string
                cidr_block = string
                assume_role = optional(string, "")
                attach_subnet_groups = list(string)
                accepter_tags = optional(map(string), {})
                requester_tags = optional(map(string), {})
            }))
            vpn_connections = map(object({
                cgw_ip = string
                attach_subnet_groups  = list(string)
            }))
            nat_gateways = map(object({
                public_subnet_group = string
                private_subnet_groups  = list(string)
            }))
            route53_resolver_settings = optional(object({
                attach_subnet_groups = list(string)
                forwarder_rules  = optional(list(string), null)
                enable_inbound_resolver = bool
            }), null)
        }))
})}
