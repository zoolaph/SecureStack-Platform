variable "groups" {
  description = "Sandbox groups"
  type = map(object({
    display_name = string
    description  = optional(string)
  }))
  default = {}
}

variable "users" {
  description = "Sandbox users"
  type = map(object({
    user_name     = string
    given_name    = string
    family_name   = string
    display_name  = string
    primary_email = string
  }))
  default = {}
}