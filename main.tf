terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region     = "${var.aws_region}"
}

module "key_pair" {
  source        = "./keypair"
  environment   = "${var.environment}"
  public_key    = "${var.public_key}"
}

module "vpc" {
  source        = "./vpc"
  environment   = "${var.environment}"
}

module "subnets" {
  source      = "./subnets"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.main_vpc_id}"
}

module "security_groups" {
  source      = "./security-groups"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.main_vpc_id}"
}

module "s3" {
  source        = "./s3"
  domain        = "${var.domain}"
  environment   = "${var.environment}"
  force_destroy = "${var.force_destroy_s3_buckets}"
}

module "bastion" {
  source      = "./bastion"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.main_vpc_id}"
}

module "instances" {
  source                     = "./instances"
  environment                = "${var.environment}"
  vpc_id                     = "${module.vpc.main_vpc_id}"
  main_host_subnet_id        = "${module.subnets.main_subnet_id}"
  dock_subnet_id             = "${module.subnets.dock_subnet_id}"
  private_ip                 = "${var.main_host_private_ip}"
  github_org_id              = "${var.github_org_id}"
  lc_user_data_file_location = "${var.lc_user_data_file_location}"
  key_name                   = "${module.key_pair.key_pair_name}"
  bastion_sg_id              = "${module.subnets.bastion_sg_id}"
  main_host_instance_type    = "${var.main_host_instance_type}"
  dock_instance_type         = "${var.dock_instance_type}"
}

module "database" {
  source                      = "./database"
  environment                 = "${var.environment}"
  username                    = "${var.db_username}"
  password                    = "${var.db_password}"
  port                        = "${var.db_port}"
  subnet_group_name           = "${module.subnets.database_subnet_group_name}"
  main_host_security_group_id = "${module.security_groups.main_security_group_id}"
  vpc_id                      = "${module.vpc.main_vpc_id}"
  instance_class              = "${var.db_instance_class}"
}
