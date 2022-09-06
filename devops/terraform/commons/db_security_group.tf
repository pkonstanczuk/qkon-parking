resource "aws_security_group" "allow_access_to_db_externally" {
  name        = "db_access_externally_${terraform.workspace}"
  tags        = local.tags
  description = "The group allows access to DBs from local machines for non production environment"
  vpc_id      = var.vpc_id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "postgres_ingress" {
  count             = var.is_production ? 0 : 1
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_access_to_db_externally.id
  description       = "Opens port for postgres"
}

resource "aws_security_group_rule" "mysql_ingress" {
  count             = var.is_production ? 0 : 1
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_access_to_db_externally.id
  description       = "Opens port for mysql"
}