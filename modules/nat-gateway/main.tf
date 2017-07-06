variable "environment" {}
variable "vpc_id" {}
variable "region" {}
variable "cluster_subnet_id" {}

resource "aws_eip" "dock_nat_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.main"]
}

resource "aws_nat_gateway" "dock_nat" {
  allocation_id = "${aws_eip.dock_nat_eip.id}"
  subnet_id = "${var.cluster_subnet_id}"
  depends_on = ["aws_internet_gateway.main"]
}

output "dock_nat_eip" {
  value = "${aws_eip.dock_nat_eip.public_ip}"
}

output "dock_nat_gateway" {
  value = "${aws_nat_gateway.dock_nat}"
}
