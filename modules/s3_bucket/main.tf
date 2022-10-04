locals {
  bucket_id = aws_s3_bucket.main-bucket.id
}

resource "aws_s3_bucket" "main-bucket" {
  bucket        = var.main_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "main-bucket-acl" {
  bucket = local.bucket_id
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "main-bucket-versioning" {


  bucket = local.bucket_id
  versioning_configuration {
    status = var.versioning
  }
}
resource "aws_s3_bucket_public_access_block" "public-access-block" {

  bucket = local.bucket_id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}
