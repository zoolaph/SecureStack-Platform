variable "identity_store_id" {
  type        = string
  description = "IAM Identity Center Identity Store ID"
}

variable "groups" {
  description = "Groups to create"
  type = map(object({
    display_name = string
    description  = optional(string)
  }))
  default = {}
}

variable "users" {
  description = "Users to create"
  type = map(object({
    user_name     = string
    given_name    = string
    family_name   = string
    display_name  = string
    primary_email = string
  }))
  default = {}
}