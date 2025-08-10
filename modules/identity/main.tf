resource "aws_identitystore_group" "this" {
  for_each          = var.groups
  identity_store_id = var.identity_store_id
  display_name      = each.value.display_name
  description       = try(each.value.description, null)
}

resource "aws_identitystore_user" "this" {
  for_each          = var.users
  identity_store_id = var.identity_store_id

  user_name    = each.value.user_name
  display_name = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.primary_email
    primary = true
    type    = "work"
  }
}