# network-endpoints — Security Group dla Interface Endpoints (Secrets/SSM)

resource "aws_security_group" "sg_endpoints" {
  vpc_id      = var.vpc_id
  name        = "${var.name_prefix}-endpoints-sg"
  description = "Interface endpoints for Secrets and SSM"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-endpoints-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_from_app_https" {
  security_group_id            = aws_security_group.sg_endpoints.id
  referenced_security_group_id = var.sg_app_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "endpoints_to_aws_https" {
  security_group_id = aws_security_group.sg_endpoints.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

