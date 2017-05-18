terraform {
  backend "local" {
    path = "kops.tfstate"
  }
}

provider "aws" {
  region     = "${var.aws_region}"
}

module "step_1" {
  source                   = "./step-1"
  environment              = "${var.environment}"
  public_key_path          = "${var.public_key_path}"
  aws_region               = "${var.aws_region}"
  domain                   = "${var.domain}"
  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  db_username              = "${var.db_username}"
  db_password              = "${var.db_password}"
  db_port                  = "${var.db_port}"
}

# Has unfortunate problem of not allowing variables
# Can variables be over
module "step_2_kops" {
  source = "./step-2-kops/"
}

module "security_groups" {
  source         = "./modules/security-groups"
  environment    = "${var.environment}"
  vpc_id         = "${module.step_1.main_vpc_id}"
  cluster_sg_ids = "${concat(module.step_2_kops.node_security_group_ids, module.step_2_kops.master_security_group_ids)}"
}

module "subnets" {
  source                = "./modules/subnets"
  environment           = "${var.environment}"
  region                = "${var.aws_region}"
  vpc_id                = "${module.step_1.main_vpc_id}"
  public_route_table_id = "${module.step_1.public_route_table_id}"
}

# Will only be used to access docks. Can we use kops created bastion?
module "bastion" {
  source        = "./modules/bastion"
  environment   = "${var.environment}"
  sg_id         = "${module.security_groups.bastion_sg_id}"
  subnet_id     = "${module.subnets.main_subnet_id}" # TODO: Change
  key_name      = "${module.step_1.key_pair_name}" #TODO Change
}

module "instances" {
  source                     = "./modules/instances"
  environment                = "${var.environment}"
  main_host_subnet_id        = "${module.subnets.main_subnet_id}" #TODO: Change
  dock_subnet_id             = "${module.subnets.dock_subnet_id}"
  private_ip                 = "${var.main_host_private_ip}" # TODO: Change
  github_org_id              = "${var.github_org_id}"
  lc_user_data_file_location = "${var.lc_user_data_file_location}"
  key_name                   = "${module.step_1.key_pair_name}" #TODO: Change also remove key pair stuff
  main_host_instance_type    = "${var.main_host_instance_type}" # TODO: CRemove not necesiary
  dock_instance_type         = "${var.dock_instance_type}"
  main_sg_id                 = "${module.security_groups.main_sg_id}" #TODO: Change
  dock_sg_id                 = "${module.security_groups.dock_sg_id}"
}

module "database" {
  source            = "./modules/database"
  environment       = "${var.environment}"
  username          = "${var.db_username}"
  password          = "${var.db_password}"
  port              = "${var.db_port}"
  subnet_group_name = "${module.subnets.database_subnet_group_name}" # TODO: Change group to also include other subnet
  security_group_id = "${module.security_groups.db_sg_id}"
  instance_class    = "${var.db_instance_class}"
}

output "environment" {
  value = "${var.environment}"
}

output "vpc_id" {
  value = "${module.step_1.main_vpc_id}"
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
  value = "${module.step_1.key_pair_name}"
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

output "dns_nameservers" {
  value = "${module.step_1.dns_nameservers}"
}

output "main_host_private_ip" {
  value = "${var.main_host_private_ip}"
}

output "kops_config_bucket" {
 value = "${module.step_1.kops_config_bucket}"
}

output "cluster_name" {
 value = "${module.step_1.cluster_name}"
}

output "ssh_public_key_path" {
  value = "${var.public_key_path}"
}
