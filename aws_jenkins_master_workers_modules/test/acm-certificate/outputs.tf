output "cert_arn" {
  value = module.acm_certificate.cert.arn
}

output "cert_domain_name" {
  value = module.acm_certificate.cert.domain_name
}