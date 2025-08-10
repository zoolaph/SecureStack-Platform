output "backend_bucket" {
  value = aws_s3_bucket.state.bucket
}

output "backend_region" {
  value = data.aws_region.current.name
}

output "backend_dynamodb_table" {
  value = aws_dynamodb_table.locks.name
}

output "kms_key_alias" {
  value = aws_kms_alias.tf_state.name
}

output "kms_key_arn" {
  value = aws_kms_key.tf_state.arn
}

output "tf_state_access_policy_arn" {
  value       = aws_iam_policy.tf_state_access.arn
  description = "Attach this policy to your terraform-apply role"
}
