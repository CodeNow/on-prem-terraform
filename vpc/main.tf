variable "environment" {}

resource "aws_vpc" "main" {
  cidr_block       = "10.10.0.0/16"

  tags {
    Name = "${var.environment}-main"
  }
}

output "main_vpc_id" {
  value = "${aws_vpc.main.id}"
}
