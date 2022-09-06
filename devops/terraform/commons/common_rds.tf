resource "aws_db_parameter_group" "mysql-8-db-param-group" {
  family = "mysql8.0"
  name   = "mysql8-with-utf-${terraform.workspace}"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
  parameter {
    name  = "collation_server"
    value = "utf8_general_ci"
  }
  tags = local.tags
}
