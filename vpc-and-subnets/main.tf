variable "environment" {}
variable "public_key" {}

resource "aws_vpc" "main" {
  cidr_block       = "10.10.0.0/16"

  tags {
    Name = "${var.environment}-main"
  }
}

resource "aws_subnet" "main-subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name       = "${var.environment}-main-subnet"
    Enviroment = "${var.environment}"
  }
}

resource "aws_subnet" "dock-subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.10.2.0/24"

  tags {
    Name       = "${var.environment}-dock-subnet"
    Enviroment = "${var.environment}"
  }
}

resource "aws_key_pair" "runnable-self-hosted" {
  key_name   = "runnable-self-hosted-key-pair"
  public_key = "${var.public_key}"
}
