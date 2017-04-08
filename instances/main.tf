variable "environment" {}
variable "subnet_id" {}

resource "aws_instance" "main-instance" {
  ami           = "singe-host-ami-build-v0.0.1"
  instance_type = "t2.xlarge"
  associate_public_ip_address = true

  security_groups = ["${var.environment}-main-host-sg"]
  subnet_id = "${var.subnet_id}"

  tags {
    Name = "${var.environment}-main"
  }
}
