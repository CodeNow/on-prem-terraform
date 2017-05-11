terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region     = "${var.aws_region}"
}

module "key_pair" {
  source          = "./keypair"
  environment     = "${var.environment}"
  public_key_path = "${var.public_key_path}"
}

module "vpc" {
  source        = "./vpc"
  environment   = "${var.environment}"
}

module "subnets" {
  source                = "./subnets"
  environment           = "${var.environment}"
  region                = "${var.aws_region}"
  vpc_id                = "${module.vpc.main_vpc_id}"
  public_route_table_id = "${module.vpc.public_route_table_id}"
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
  source        = "./bastion"
  environment   = "${var.environment}"
  sg_id         = "${module.security_groups.bastion_sg_id}"
  subnet_id     = "${module.subnets.main_subnet_id}"
  key_name      = "${module.key_pair.key_pair_name}"
}

module "instances" {
  source                     = "./instances"
  environment                = "${var.environment}"
  main_host_subnet_id        = "${module.subnets.main_subnet_id}"
  dock_subnet_id             = "${module.subnets.dock_subnet_id}"
  private_ip                 = "${var.main_host_private_ip}"
  github_org_id              = "${var.github_org_id}"
  lc_user_data_file_location = "${var.lc_user_data_file_location}"
  key_name                   = "${module.key_pair.key_pair_name}"
  main_host_instance_type    = "${var.main_host_instance_type}"
  dock_instance_type         = "${var.dock_instance_type}"
  main_sg_id                 = "${module.security_groups.main_sg_id}"
  dock_sg_id                 = "${module.security_groups.dock_sg_id}"
}

module "database" {
  source            = "./database"
  environment       = "${var.environment}"
  username          = "${var.db_username}"
  password          = "${var.db_password}"
  port              = "${var.db_port}"
  subnet_group_name = "${module.subnets.database_subnet_group_name}"
  security_group_id = "${module.security_groups.db_sg_id}"
  instance_class    = "${var.db_instance_class}"
}

output "environment" {
  value = "${var.environment}"
}

output "vpc_id" {
  value = "${module.vpc.main_vpc_id}"
}

output "main_host_subnet_id" {
  value = "${module.subnets.main_subnet_id}"
}

output "dock_subnet_id" {
  value = "${module.subnets.dock_subnet_id}"
}

output "database_subnet_group_name" {
  value = "${module.subnets.database_subnet_group_name}"
}

output "key_pair_name" {
  value = "${module.key_pair.key_pair_name}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "postgres_user" {
  value = "${var.db_username}"
}

output "postgres_password" {
  value = "${var.db_password}"
}

output "main_host_private_ip" {
  value = "${var.main_host_private_ip}"
}
