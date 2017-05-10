# General

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
  type        = "string"
}

variable "environment" {
  description = "Name given to the enviroment in which Runnable is being deployed. This can be any name. It is used in multiple places to name resources."
  default     = "runnable-on-prem"
  type        = "string"
}

variable "domain" {
  description = "Main domain for your Runnable installation. You should already own this domain and have certs for it."
  type        = "string"
}

# Key Pair

variable "public_key" {
  description = "Public key for key which will be used for sshing into instances through bastion"
  type        = "string"
}

# S3 Buckets

variable "force_destroy_s3_buckets" {
  description = "Forces destroy of S3 buckets and deletes all their content. Default to false. Use this only when tearing down an environment. Before running `terraform destroy`, `terraform apply` must be run to updates buckets."
  type        = "string"
  default     = "true" # https://www.terraform.io/docs/configuration/variables.html#booleans
}

# Databases

variable "db_username" {
  description = "Username for RDS Postgres instance"
  type        = "string"
}

variable "db_password" {
  description = "Password for RDS Postgres instance"
  type        = "string"
}

variable "db_port" {
  description = "Port for RDS Postgres instance"
  default     = 5432
  type        = "string"
}

variable "db_instance_class" {
  description = "Type of instance that will be used for database"
  type        = "string"
  default     = "db.t2.small"
}

# EC2 Instances

variable "main_host_private_ip" {
  description = "Private IP address in VPC for main-host. This is important because ip address is encoded in launch configuration for docks."
  default     = "10.10.1.100"
  type        = "string"
}

variable "main_host_instance_type" {
  description = "Type of instance that will be used for the main host"
  type        = "string"
  default     = "m4.2xlarge"
}

variable "dock_instance_type" {
  description = "Type of instance that will be used for all docks"
  type        = "string"
  default     = "m4.large"
}

variable "github_org_id" {
  description = "Github organization id for which ASG will be created"
  type        = "string"
}

variable "lc_user_data_file_location" {
  description = "Location for file generated for launch configuration. This file needs to have correct IPs, ports, and files"
  type = "string"
}
