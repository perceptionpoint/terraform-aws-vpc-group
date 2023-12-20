terraform {
  required_providers {
    aws = {
      configuration_aliases = [ aws.peer_vpc ]
    }
  }
}
