# get already publicly available hosted zones
data "aws_route53_zone" "dns" {
  provider = aws.region_master
  name     = var.dns_name
}

resource "aws_route53_record" "jenkins" {
  provider = aws.region_master

  depends_on = [
    module.jenkins_master_workers
  ]

  zone_id = data.aws_route53_zone.dns.zone_id
  name    = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  type    = "A"
  alias {
    name                   = module.jenkins_master_workers.alb_dns_name
    zone_id                = module.jenkins_master_workers.alb_zone_id
    evaluate_target_health = true
  }
}