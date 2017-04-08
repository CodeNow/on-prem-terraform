provider "aws" {
  region     = "${var.aws_region}"
}

module "s3" {
  source = "./s3"
  domain = "${var.domain}"
  environment = "${var.environment}"
}

module "database" {
  source = "./database"
  environment = "${var.environment}"
  db_username = "${var.db_username}"
  db_password = "${var.db_password}"
  db_port = "${var.db_port}"
  db_subnet_group_name = "${var.db_subnet_group_name}"
}
