variable "environment" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.environment}-main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.environment}-main-ig"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.environment}-main-route-table"
  }
}

resource "aws_main_route_table_association" "main_route_table" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

output "main_vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.main.id}"
}
