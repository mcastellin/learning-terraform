# Create ACM certificate for SSL connections
resource "aws_acm_certificate" "jenkins-lb-https" {
  provider          = aws.region_master
  domain_name       = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  validation_method = "DNS" # we need to add the CNAME validation record to complete DNS validation
  tags = {
    "Name" = "Jenkins-ACM"
  }
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.region_master
  certificate_arn         = aws_acm_certificate.jenkins-lb-https.arn
  for_each                = aws_route53_record.cert-validation # refences all of the created cert validations
  validation_record_fqdns = [aws_route53_record.cert-validation[each.key].fqdn]

}