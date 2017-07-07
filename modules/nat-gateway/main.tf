variable "environment" {}
variable "vpc_id" {}
variable "subnet_id" {}

resource "aws_eip" "dock_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "dock_nat" {
  allocation_id = "${aws_eip.dock_nat_eip.id}"
  subnet_id     = "${var.subnet_id}"
}

output "dock_nat_eip" {
  value = "${aws_eip.dock_nat_eip.public_ip}"
}

output "dock_nat_gateway_id" {
  value = "${aws_nat_gateway.dock_nat.id}"
}
