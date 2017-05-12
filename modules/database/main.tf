variable "environment" {}
variable "username" {}
variable "password" {}
variable "port" {}
variable "subnet_group_name" {}
variable "security_group_id" {}
variable "instance_class" {}

resource "aws_db_instance" "main_postgres_db" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "9.5.2"
  instance_class         = "${var.instance_class}"
  name                   = "big_poppa"
  username               = "${var.username}"
  password               = "${var.password}"
  port                   = "${var.port}"
  db_subnet_group_name   = "${var.subnet_group_name}"
  vpc_security_group_ids = ["${var.security_group_id}"]
  skip_final_snapshot    = true
}
