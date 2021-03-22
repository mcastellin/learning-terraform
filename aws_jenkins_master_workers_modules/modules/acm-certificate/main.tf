# acm-certificate module
# Configures an ACM certificate to be used in the hosted zone
terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}