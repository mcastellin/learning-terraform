output "cert" {
  value = {
    arn         = aws_acm_certificate.lb_https_cert.arn
    domain_name = aws_acm_certificate.lb_https_cert.domain_name
  }
}