output "Jenkins-URL" {
  value = aws_route53_record.jenkins.fqdn
}