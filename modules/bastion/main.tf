variable "environment" {}
variable "subnet_id" {}
variable "key_name" {}
variable "sg_id" {}

resource "aws_instance" "bastion_instance" {
  ami                         = "ami-5189a661"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${var.sg_id}"]
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${var.key_name}"

  associate_public_ip_address = true
  source_dest_check = false

  tags {
    Name = "${var.environment}-bastion"
  }
}
