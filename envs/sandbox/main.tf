# Safe noop resource (writes to state; no external effect).
resource "terraform_data" "probe" {
  input = "hello-sandbox"
}

# Reuse the shared module to create users & groups in Identity Center.
# IMPORTANT: We pass the sso_home provider to ensure calls go to
# the Identity Center home region (required by AWS APIs).
module "identity" {
  source            = "../../modules/identity"
  identity_store_id = local.identity_store_id
  groups            = var.groups
  users             = var.users

  providers = {
    aws = aws.sso_home
  }
}
