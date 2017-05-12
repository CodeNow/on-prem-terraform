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

module "subnets" {
  source                = "../modules/subnets"
  environment           = "${var.environment}"
  region                = "${var.aws_region}"
  vpc_id                = "${module.vpc.main_vpc_id}"
  public_route_table_id = "${module.vpc.public_route_table_id}"
}

module "security_groups" {
  source      = "../modules/security-groups"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.main_vpc_id}"
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
