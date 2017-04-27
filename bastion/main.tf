variable "environment" {}
variable "ami" {}
variable "subnet_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "sg_id" {}

resource "aws_instance" "bastion_instance" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${var.sg_id}"]
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${var.key_name}"

  tags {
    Name = "${var.environment}-bastion"
  }
}
