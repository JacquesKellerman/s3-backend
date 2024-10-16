# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE AN S3 BUCKET AND DYNAMODB TABLE TO USE AS A TERRAFORM BACKEND
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# CREATE THE S3 BUCKET
# ------------------------------------------------------------------------------

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_state" {
  # With account id, this S3 bucket names can be *globally* unique.
  bucket = "${local.account_id}-${lookup(local.region_short_names, var.aws_region, "aws")}-${var.application_name}-terraform-states"
  #bucket = "${local.account_id}-${lookup(local.region_short_names, var.aws_region, random_id.bucket_suffix.hex)}-${var.application_name}-terraform-states"

  tags = {
    Environment = var.environment
    Description = "This S3 bucket is used as the Terraform backend storage of the state for the ${var.application_name} application."
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for the S3 bucket so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption (SSE-S3) for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_bucket_sse" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Using SSE-S3 encryption (AES-256)
    }
  }
}

# # Optional: Add a bucket policy to control access
# resource "aws_s3_bucket_policy" "tf_state_bucket_policy" {
#   bucket = aws_s3_bucket.terraform_state.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action   = "s3:GetObject",
#         Resource = "${aws_s3_bucket.terraform_state.arn}/*"
#       }
#     ]
#   })
# }

# ------------------------------------------------------------------------------
# CREATE THE DYNAMODB TABLE
# ------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${local.account_id}-${lookup(local.region_short_names, var.aws_region, "aws")}-${var.application_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
