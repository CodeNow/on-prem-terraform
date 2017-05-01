variable "public_key" {}
variable "environment" {}

resource "aws_key_pair" "main_key" {
  key_name = "${var.environment}-key-pair"
  public_key = "${var.public_key}"
}

output "key_pair_name" {
  value = "${aws_key_pair.main_key.key_name}"
}

