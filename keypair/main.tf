variable "public_key_path" {}
variable "environment" {}

resource "aws_key_pair" "main_key" {
  key_name = "${var.environment}-key-pair"
  public_key = "${file("${var.public_key_path}")}"
}

output "key_pair_name" {
  value = "${aws_key_pair.main_key.key_name}"
}

