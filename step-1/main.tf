variable environment {}
variable public_key_path {}
variable aws_region {}
variable domain {}
variable force_destroy_s3_buckets {}
variable db_username {}
variable db_password {}
variable db_port {}

module "key_pair" {
  source          = "../modules/keypair"
  environment     = "${var.environment}"
  public_key_path = "${var.public_key_path}"
}

module "vpc" {
  source        = "../modules/vpc"
  environment   = "${var.environment}"
}

module "route53" {
  source      = "../modules/route53"
  domain        = "${var.domain}"
  environment   = "${var.environment}"
  force_destroy = "${var.force_destroy_s3_buckets}"
}

module "s3" {
  source        = "../modules/s3"
  domain        = "${var.domain}"
  environment   = "${var.environment}"
  force_destroy = "${var.force_destroy_s3_buckets}"
}

output "main_vpc_id" {
  value = "${module.vpc.main_vpc_id}"
}

output "public_route_table_id" {
  value = "${module.vpc.public_route_table_id}"
}

output "key_pair_name" {
  value = "${module.key_pair.key_pair_name}"
}

output "dns_nameservers" {
  value = "${module.route53.nameservers}"
}

output "cluster_name" {
 value = "${module.route53.cluster_name}"
}

output "kops_config_bucket" { #TODO: Update
 value = "${module.s3.kops_config_bucket}"
}
