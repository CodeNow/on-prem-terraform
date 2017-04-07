provider "aws" {
  region     = "${var.aws_region}"
}

module "s3" {
  source = "./s3"
  domain = "${var.domain}"
  environment = "${var.environment}"
}

module "security-groups" {
  source = "./security-groups"
  environment = "${var.environment}"
}
