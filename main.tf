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
  source                     = "./instances-and-security-groups"
  environment                = "${var.environment}"
  vpc_id                     = "${var.main_host_vpc_id}"
  main_host_subnet_id        = "${var.main_host_subnet_id}"
  dock_subnet_id             = "${var.dock_subnet_id}"
  private_ip                 = "${var.main_host_private_ip}"
  github_org_id              = "${var.github_org_id}"
  lc_user_data_file_location = "${var.lc_user_data_file_location}"
  key_name                   = "${var.key_name}"
  bastion_sg_id              = "${var.bastion_sg_id}"
}