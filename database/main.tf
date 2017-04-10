variable "environment" {}
variable "username" {}
variable "password" {}
variable "port" {}
variable "subnet_group_name" {}

resource "aws_db_instance" "main_postgres_db" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "9.5.2"
  instance_class       = "db.t2.small"
  name                 = "big_poppa"
  username             = "${var.username}"
  password             = "${var.password}"
  port                 = "${var.port}"
  db_subnet_group_name = "${var.subnet_group_name}"
}
