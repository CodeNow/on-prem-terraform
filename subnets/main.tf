variable "environment" {}
variable "vpc_id" {}
variable "region" {}
variable "public_route_table_id" {}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags {
    Name       = "${var.environment}-main-subnet"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "dock_subnet" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.10.2.0/24"
  availability_zone = "${var.region}b"

  tags {
    Name       = "${var.environment}-dock-subnet"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "${var.environment}-database-subnet-group"
  # NOTE: What subnets should this have?
  subnet_ids = ["${aws_subnet.main_subnet.id}", "${aws_subnet.dock_subnet.id}"]

  tags {
    Name       = "${var.environment}-database-subnet-group"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.main_subnet.id}"
  route_table_id = "${var.public_route_table_id}"
}

output "main_subnet_id" {
  value = "${aws_subnet.main_subnet.id}"
}

output "dock_subnet_id" {
  value = "${aws_subnet.dock_subnet.id}"
}

output "database_subnet_group_name" {
  value = "${aws_db_subnet_group.database_subnet_group.name}"
}
