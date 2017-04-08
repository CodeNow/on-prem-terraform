variable "environment" {}
variable "db_username" {}
variable "db_password" {}
variable "db_port" {}
variable "db_subnet_group_name" {}

resource "aws_db_instance" "main_postgres_db" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "9.5.2"
  instance_class       = "db.t2.small"
  name                 = "big_poppa"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  port                 = "${var.db_port}"
  db_subnet_group_name = "${var.db_subnet_group_name}"
}
