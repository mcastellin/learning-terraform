# get already publicly available hosted zones
data "aws_route53_zone" "dns" {
  name = var.dns_name
}

resource "aws_route53_record" "cert-validation" {
  # can use in any terraform resource to generate an "each" object populated with an iteration
  for_each = {
    for val in aws_acm_certificate.jenkins-lb-https.domain_validation_options :
    val.domain_name => {
      name   = val.resource_record_name
      record = val.resource_record_value
      type   = val.resource_record_type
    }
  }

  # then will probably create as many resources as we have elements in each, just like the count tf attribute
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns.zone_id
}