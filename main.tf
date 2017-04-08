provider "aws" {
  region     = "${var.aws_region}"
}

module "s3" {
  source      = "./s3"
  domain      = "${var.domain}"
  environment = "${var.environment}"
}

module "security-groups" {
  source      = "./security-groups"
  environment = "${var.environment}"
}

module "database" {
  source            = "./database"
  environment       = "${var.environment}"
  username          = "${var.db_username}"
  password          = "${var.db_password}"
  port              = "${var.db_port}"
  subnet_group_name = "${var.db_subnet_group_name}"
}

module "instances" {
  source      = "./instances"
  environment = "${var.environment}"
  subnet_id   = "${var.main_host_subnet_id}"
}
