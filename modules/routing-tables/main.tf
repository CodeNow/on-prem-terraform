variable "vpc_id" {}
variable "dock_nat_id" {}

resource "aws_route_table" "docks_route_table" {
    vpc_id = "${var.vpc_id}"
 
    tags {
        Name = "Docks route table"
    }
}

resource "aws_route" "private_route" {
  route_table_id  = "${aws_route_table.docks_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${var.dock_nat_id}"
}

resource "aws_main_route_table_association" "docks_route_table" {
  vpc_id         = "${var.vpc_id}"
  route_table_id = "${aws_route_table.docks_route_table.id}"
}
