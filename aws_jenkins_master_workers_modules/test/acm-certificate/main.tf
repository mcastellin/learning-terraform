terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

module "acm_certificate" {
  source = "../../modules/acm-certificate"

  dns_name      = var.dns_name
  subdomain     = var.subdomain
  tag_cert_name = var.tag_cert_name
}