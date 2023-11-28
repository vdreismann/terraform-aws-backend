/*
 * Module: terraform-aws-backend
 *
 * Bootstrap your terraform backend on AWS.
 *
 * This module configures resources for state locking for terraform >= 0.9.0
 * https://github.com/hashicorp/terraform/blob/master/CHANGELOG.md#090-march-15-2017
 *
 * This template creates and/or manages the following resources
 *   - An S3 Bucket for storing terraform state
 *   - An S3 Bucket for storing logs from the state bucket
 *   - A DynamoDB table to be used for state locking and consistency
 *
 * The DynamoDB state locking table is optional: to disable,
 * set the 'dynamodb_lock_table_enabled' variable to false.
 * For more info on how terraform handles boolean variables:
 *   - https://www.terraform.io/docs/configuration/variables.html
 *
 * If using an existing S3 Bucket, perform a terraform import on your bucket
 * into your terraform-aws-backend module instance:
 *
 * $ terraform import module.backend.aws_s3_bucket.tf_backend_bucket <your_s3_bucket_name>
 *
 * where the 'backend' portion is the name you choose:
 *
 * module "backend" {
 *   source = "github.com/samstav/terraform-aws-backend"
 * }
 *
 */

resource "aws_s3_bucket" "tf_backend_bucket" {
  bucket = var.backend_bucket

  tags = {
    ManagedByTerraform = "true"
    TerraformModule    = "terraform-aws-backend"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.tf_backend_bucket.id

  rule {
    id = "state_expiration"
    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kms_encryption" {
  bucket = aws_s3_bucket.tf_backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "enable" {
  bucket = aws_s3_bucket.tf_backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

