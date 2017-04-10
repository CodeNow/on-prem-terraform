# General

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

# Databases

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

# EC2 Instances

variable "main_host_vpc_id" {
  description = "VPC in which security groups and instance for main host will be created."
}

variable "main_host_subnet_id" {
  description = "Subnet in which main host EC2 instance will be created. Subnet must be part of VPC in `main_host_vpc_id`"
}

variable "main_host_private_ip" {
  description = "Private IP address in VPC for main-host. This is important because ip address is encoded in launch configuration for docks."
}
