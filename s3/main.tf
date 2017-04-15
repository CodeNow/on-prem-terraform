variable "domain" {}
variable "environment" {}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "app.${var.domain}"
  acl    = "public-read"

  tags {
    Description = "Bucket to host Angular application"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.domain}"
  acl    = "public-read"

  tags {
    Description = "Bucket to host FE site for logging in"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket" "runnable_vault" {
  bucket = "runnable.vault.${var.environment}"
  acl    = "private"

  tags {
    Description = "Bucket to server as a backend for vault"
  }
}

resource "aws_s3_bucket" "context_resources" {
  bucket = "runnable.context.resources.${var.environment}"
  acl    = "private"

  tags {
    Description = "Bucket to save resources for contexts"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "deploy_keys" {
  bucket = "runnable.deploykeys.${var.environment}"
  acl    = "private"

  tags {
    Description = "Bucket to Github deploy keys"
  }
}

resource "aws_s3_bucket" "container_logs" {
  bucket = "${var.environment}.container-logs"
  acl    = "private"

  tags {
    Description = "Bucket to save container logs"
  }
}

resource "aws_s3_bucket" "registry" {
  bucket = "runnableimages.${var.environment}"
  acl    = "private"

  tags {
    Description = "Bucket to service as the registry backend"
  }
}
