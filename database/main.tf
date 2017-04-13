variable "environment" {}
variable "username" {}
variable "password" {}
variable "port" {}
variable "subnet_group_name" {}
variable "vpc_id" {}
variable "main_host_security_group_id" {}

resource "aws_security_group" "database_sg" {
  name        = "${var.environment}-database-sg"
  description = "Allow inbound traffic from main host to DB port"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${var.main_host_security_group_id}"]
  }
}

resource "aws_db_instance" "main_postgres_db" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "9.5.2"
  instance_class         = "db.t2.small"
  name                   = "big_poppa"
  username               = "${var.username}"
  password               = "${var.password}"
  port                   = "${var.port}"
  db_subnet_group_name   = "${var.subnet_group_name}"
  vpc_security_group_ids = ["${aws_security_group.database_sg.id}"]
  skip_final_snapshot    = true
}
