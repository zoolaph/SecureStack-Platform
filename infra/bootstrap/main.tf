# Discover account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# Create a customer managed KMS key for state-at-rest
resource "aws_kms_key" "tf_state" {
  description             = "KMS key for Terraform state at rest"
  enable_key_rotation     = true # auto-rotate yearly
  deletion_window_in_days = 30   # safety net
}
resource "aws_kms_alias" "tf_state" {
  name          = "alias/tf-state" # human-friendly handle
  target_key_id = aws_kms_key.tf_state.key_id
}

# Create the S3 bucket for state
locals {
  state_bucket_name = "tf-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}
resource "aws_s3_bucket" "state" {
  bucket = local.state_bucket_name
}

# Block public access (defense-in-depth)
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Turn on versioning (rollbacks)
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt the bucket using your CMK (not AES256)

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.tf_state.arn
    }
    bucket_key_enabled = true
  }
}

# Bucket policy to deny risky operations create the policy then apply it
data "aws_iam_policy_document" "bucket_policy" {
  # deny non-TLS (http) access
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  statement {
    sid     = "DenyUnEncryptedObjectUploads"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.state.arn}/*"]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}
resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# DynamoCB lock table
resource "aws_dynamodb_table" "locks" {
  name         = "tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# IAM policy you’ll attach to your CI role
data "aws_iam_policy_document" "tf_state_access" {
  statement {
    sid       = "S3StateAccess"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.state.arn]
  }
  statement {
    sid       = "S3ObjectAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.state.arn}/*"]
  }
  statement {
    sid    = "DynamoDBLocks"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable"
    ]
    resources = [aws_dynamodb_table.locks.arn]
  }
  statement {
    sid       = "KMSUse"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = [aws_kms_key.tf_state.arn]
  }
}

resource "aws_iam_policy" "tf_state_access" {
  name   = "TerraformStateAccess"
  policy = data.aws_iam_policy_document.tf_state_access.json
}
