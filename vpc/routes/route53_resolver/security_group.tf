resource "aws_security_group" "route53-resolver-sg" {
  vpc_id = var.vpc_id
  name = "route53-resolver"
  description = "route53-resolver"

  ingress {
    description = ""
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = ""
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = ""
    from_port   = 433
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
  description = ""
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}
