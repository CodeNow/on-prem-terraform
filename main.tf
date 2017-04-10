provider "aws" {
  region     = "${var.aws_region}"
}

module "s3" {
  source      = "./s3"
  domain      = "${var.domain}"
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

module "instances-and-security-groups" {
  source      = "./instances-and-security-groups"
  environment = "${var.environment}"
  vpc_id      = "${var.main_host_vpc_id}"
  subnet_id   = "${var.main_host_subnet_id}"
  private_ip  = "${var.main_host_private_ip}"
}