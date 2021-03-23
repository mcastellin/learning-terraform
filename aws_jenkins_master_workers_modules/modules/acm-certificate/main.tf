# acm-certificate module
# Configures an ACM certificate to be used in the hosted zone
terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

locals {
  domain_name = trimspace(var.subdomain) != "" ? join(".", [var.subdomain, data.aws_route53_zone.dns.name]) : data.aws_route53_zone.dns.name
}

# Create ACM certificate for SSL connections
resource "aws_acm_certificate" "lb_https_cert" {
  domain_name       = local.domain_name
  validation_method = "DNS" # we need to add the CNAME validation record to complete DNS validation
  tags = {
    "Name" = format("%s-ACM", var.tag_cert_name)
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.lb_https_cert.arn
  for_each                = aws_route53_record.cert-validation # refences all of the created cert validations
  validation_record_fqdns = [aws_route53_record.cert-validation[each.key].fqdn]
}