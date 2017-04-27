variable "environment" {}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name       = "${var.environment}-main-subnet"
    Enviroment = "${var.environment}"
  }
}

resource "aws_subnet" "dock_subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.10.2.0/24"

  tags {
    Name       = "${var.environment}-dock-subnet"
    Enviroment = "${var.environment}"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "${var.enviroment}-database-subnet-group"
  subnet_ids = ["${aws_subnet.main-subnet"]

  tags {
    Name       = "${var.enviroment}-database-subnet-group"
    Enviroment = "${var.enviroment}"
  }
}

output "main_subnet_id" {
  value = "${aws_subnet.main_subnet.id}"
}

output "dock_subnet_id" {
  value = "${aws_subnet.dock_subnet.id}"
}

output "database_subnet_group_name" {
  value = "${aws_subnet.database_subnet_group.name}"
}
