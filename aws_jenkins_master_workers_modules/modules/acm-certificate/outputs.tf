output "cert_arn" {
  value = aws_acm_certificate.jenkins-lb-https.arn
}