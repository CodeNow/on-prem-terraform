variable "environment" {}
variable "vpc_id" {}
variable "cluster_sg_ids" { type = "list" }

resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Allow ssh access through this box"
  vpc_id      = "${var.vpc_id}"

  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = false
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dock_sg" {
  name        = "${var.environment}-dock-sg"
  description = "Allow all traffic from kube cluster host and between docks"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["${var.cluster_sg_ids}"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8201
    protocol    = "tcp"
    security_groups = ["${var.cluster_sg_ids}"]
  }

  ingress {
    from_port   = 4242
    to_port     = 4242
    protocol    = "tcp"
    security_groups = ["${var.cluster_sg_ids}"]
  }

  ingress {
    from_port   = 29006
    to_port     = 29007
    protocol    = "tcp"
    security_groups = ["${var.cluster_sg_ids}"]
  }

  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    security_groups = ["${var.cluster_sg_ids}"]
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "udp"
    self        = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_sg" {
  name        = "${var.environment}-database-sg"
  description = "Allow inbound traffic from kube cluster to DB port"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${var.cluster_sg_ids}"]
  }
}

output "bastion_sg_id" {
  value = "${aws_security_group.bastion_sg.id}"
}

output "db_sg_id" {
  value = "${aws_security_group.database_sg.id}"
}

output "dock_sg_id" {
  value = "${aws_security_group.dock_sg.id}"
}
