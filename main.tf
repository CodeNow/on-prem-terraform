terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region     = "${var.aws_region}"
}

module "vpc-and-subnets" {
  source        = "./vpc-and-subnets"
  environment   = "${var.environment}"
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIf2LaAVw5wnc877az6Z4RdgAoRpJSJT+G7KHw+2Rv888PIf9vfTbIf/3uT8wRbhwt8jau3f2rK7AhFIQo4rLYhBYWQ+dUvNKyjpNc5ZZE7jwmtD2JLPI2aPi1ocAmFwIf5l6Gzaxkkko9iFP7hZD8dvHX00+n2m6/RvHUnbC62I1vd7JvGuYVJlhtkRpeEW0f42//l0q+UbIDw/eEs72w2YrO8VUhCE/0kvoZ8dyoz3CxeJqepgihgsOsNehq8YW93COR+Ywh3sRqv009GOuLJC02xtek6dyQwLG2L1pQJTyuvDCSsleB8kp9S9yDLu1Xlwjd/HQS3zqWREJ/ENDb"
}

module "security-groups" {
  source        = "./vpc-and-subnets"
}

module "s3" {
  source        = "./s3"
  domain        = "${var.domain}"
  environment   = "${var.environment}"
  force_destroy = "${var.force_destroy_s3_buckets}"
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
  main_host_instance_type    = "${var.main_host_instance_type}"
  dock_instance_type         = "${var.dock_instance_type}"
}

module "database" {
  source                      = "./database"
  environment                 = "${var.environment}"
  username                    = "${var.db_username}"
  password                    = "${var.db_password}"
  port                        = "${var.db_port}"
  subnet_group_name           = "${var.db_subnet_group_name}"
  main_host_security_group_id = "${module.instances-and-security-groups.main_security_group_id}"
  vpc_id                      = "${var.main_host_vpc_id}"
  instance_class              = "${var.db_instance_class}"
}
