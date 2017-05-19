variable "environment" {}
variable "username" {
  default = "pg-runnable"
}
variable "password" {}
variable "port" {}
variable "subnet_group_name" {}
variable "security_group_id" {}
variable "instance_class" {}

resource "random_id" "password" {
  byte_length = "20"
}

resource "aws_db_instance" "main_postgres_db" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "9.5.2"
  instance_class         = "${var.instance_class}"
  name                   = "big_poppa"
  username               = "${var.username}"
  password               = "${random_id.password.b64}"
  port                   = "${var.port}"
  db_subnet_group_name   = "${var.subnet_group_name}"
  vpc_security_group_ids = ["${var.security_group_id}"]
  skip_final_snapshot    = true
}

output "username" {
  value = "${var.username}"
}

output "password" {
  value = "${random_id.password.b64}"
}
