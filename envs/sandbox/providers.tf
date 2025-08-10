# Workload region (e.g., eu-west-3 / Paris)
provider "aws" {
    region = "eu-west-3"

    default_tags {
      tags = {
        Project = "SecureStack"
        Environment = "sandbox"
        ManagedBy = "Terraform"
      }
    }   
}

# SSO home region (replace with your actual SSO home region)
provider "aws" {
    alias = "soo_home"
    region = "eu-west-3"

    default_tags {
      tags = {
        Project = "SecureStack"
        Environment = "sandbox"
        ManagedBy = "Terraform"
      }      
    }
}

# Identity Center instance discovery MUST be in SSO home region
data "aws_ssoadmin_instances" "this" {
  provider = aws.sso_home
}

locals {
  identity_store_id = data.aws_ssoadmin_instances.this.instances[0].identity_store_id
}