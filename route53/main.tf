variable "environment" {}
variable "domain" {}
variable "force_destroy" {}

resource "aws_route53_zone" "main" {
  name          = "kubernetes.${var.domain}"
  force_destroy = "${var.force_destroy}"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "main-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "kubernetes.${var.domain}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.main.name_servers.0}",
    "${aws_route53_zone.main.name_servers.1}",
    "${aws_route53_zone.main.name_servers.2}",
    "${aws_route53_zone.main.name_servers.3}",
  ]
}

output "nameservers" {
  value = [
    "${aws_route53_zone.main.name_servers.0}",
    "${aws_route53_zone.main.name_servers.1}",
    "${aws_route53_zone.main.name_servers.2}",
    "${aws_route53_zone.main.name_servers.3}",
  ]
}
