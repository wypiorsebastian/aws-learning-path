# network-core — Security Groups (W04-sg-nacl-baseline)
# sg_alb (ALB), sg_app (ECS/Lambda), sg_rds (RDS)
# Reguły tworzone przez aws_security_group_rule — unika cyklicznych zależności SG.

# --- sg_alb (ALB) ---

resource "aws_security_group" "sg_alb" {
  vpc_id      = aws_vpc.this.id
  name        = "${var.name_prefix}-alb-sg"
  description = "ALB: ingress 80/443 z Internetu, egress do sg_app:${var.app_port}"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP z Internetu"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS z Internetu"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.sg_alb.id
  referenced_security_group_id = aws_security_group.sg_app.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

# Domyślna egress 0.0.0.0/0 pozostaje; aws_security_group_rule nie usuwa jej.
# Least-privilege egress tylko do sg_app byłoby wymagało inline egress (cykl z sg_app).
# Do hardeningu: rozważyć osobny moduł albo aws_security_group z lifecycle.

# --- sg_app (ECS/Lambda) ---

resource "aws_security_group" "sg_app" {
  vpc_id      = aws_vpc.this.id
  name        = "${var.name_prefix}-ecs-sg"
  description = "ECS/Lambda: ingress z ALB, egress do RDS i AWS/Internet"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-ecs-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.sg_app.id
  referenced_security_group_id = aws_security_group.sg_alb.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
  security_group_id            = aws_security_group.sg_app.id
  referenced_security_group_id = aws_security_group.sg_rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_https" {
  security_group_id = aws_security_group.sg_app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS (S3, Secrets, SSM, ECR, itp.)"
}

resource "aws_vpc_security_group_egress_rule" "app_to_http" {
  security_group_id = aws_security_group.sg_app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP (nuget, package feeds)"
}

# --- sg_rds (RDS PostgreSQL) ---

resource "aws_security_group" "sg_rds" {
  vpc_id      = aws_vpc.this.id
  name        = "${var.name_prefix}-rds-sg"
  description = "RDS: ingress z ECS/Lambda na 5432"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id            = aws_security_group.sg_rds.id
  referenced_security_group_id = aws_security_group.sg_app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
