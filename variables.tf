variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "environment" {
  description = "Name given to the enviroment in which Runnable is being deployed. This can be any name. It is used in multiple places to name resources."
  default     = "runnable-on-prem"
}

variable "domain" {
  description = "Main domain for your Runnable installation. You should already own this domain and have certs for it."
  default     = "runnablewow.com"
}
