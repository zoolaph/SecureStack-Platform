output "group_ids" {
  description = "Group IDs keyed by input key"
  value       = { for k, g in aws_identitystore_group.this : k => g.group_id }
}

output "user_ids" {
  description = "User IDs keyed by input key"
  value       = { for k, u in aws_identitystore_user.this : k => u.user_id }
}