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
}

variable "db_username" {
  description = "Username for RDS Postgres instance"
}

variable "db_password" {
  description = "Password for RDS Postgres instance"
}

variable "db_port" {
  description = "Port for RDS Postgres instance"
  default = 5432
}

variable "db_subnet_group_name" {
  description = "Subnet in which database will be created"
}
