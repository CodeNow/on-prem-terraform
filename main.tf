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
  cluster_subnet_id     = "${module.step_2_kops.node_subnet_ids[0]}" # Currently only handle one subnet for cluster
}

# Will only be used to access docks. Can we use kops created bastion?
module "bastion" {
  source      = "./modules/bastion"
  environment = "${var.environment}"
  sg_id       = "${module.security_groups.bastion_sg_id}"
  subnet_id   = "${module.subnets.cluster_subnet_id}"
  key_name    = "${module.step_1.key_pair_name}"
}

module "instances" {
  source                     = "./modules/instances"
  environment                = "${var.environment}"
  dock_subnet_id             = "${module.subnets.dock_subnet_id}"
  github_org_id              = "${var.github_org_id}"
  lc_user_data_file_location = "${var.lc_user_data_file_location}"
  key_name                   = "${module.step_1.key_pair_name}"
  dock_instance_type         = "${var.dock_instance_type}"
  dock_sg_id                 = "${module.security_groups.dock_sg_id}"
}

module "database" {
  source            = "./modules/database"
  environment       = "${var.environment}"
  port              = "${var.db_port}"
  subnet_group_name = "${module.subnets.database_subnet_group_name}"
  security_group_id = "${module.security_groups.db_sg_id}"
  instance_class    = "${var.db_instance_class}"
}

output "environment" {
  value = "${var.environment}"
}

output "vpc_id" {
  value = "${module.step_1.main_vpc_id}"
}

output "cluster_subnet_id" {
  value = "${module.subnets.cluster_subnet_id}"
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
  value = "${module.database.username}"
}

output "postgres_password" {
  value = "${module.database.password}"
  sensitive = true
}

output "postgres_host" {
  value = "${module.database.host}"
  sensitive = true
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

output "bastion_ip_address" {
  value = "${module.bastion.ip_address}"
}

output "kube_cluster_sg_ids" {
  value = "${concat(module.step_2_kops.node_security_group_ids, module.step_2_kops.master_security_group_ids)}"
}
