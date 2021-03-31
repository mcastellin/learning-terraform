
module "vpc" {
  source = "./modules/aws-peered-vpc"

  # aws-peered-vpc module needs multiple aws providers to be explicitly
  # passed down to be able to create resources in two different VPCs
  providers = {
    aws.region_master = aws.region_master
    aws.region_peer   = aws.region_worker
  }

  region_master = var.region_master
  region_peer   = var.region_worker
}

module "acm_certificate" {
  source = "./modules/acm-certificate"

  providers = {
    aws = aws.region_master
  }

  dns_name      = var.dns_name
  subdomain     = "jenkins"
  tag_cert_name = "Jenkins"
}


module "jenkins_master_workers" {
  source = "./modules/jenkins-master-workers"

  depends_on = [
    module.vpc,
    module.acm_certificate
  ]

  providers = {
    aws.region_master  = aws.region_master
    aws.region_workers = aws.region_worker

  }

  master_vpc  = module.vpc.master
  workers_vpc = module.vpc.peer

  workers_count       = 2
  ssl_enabled         = true
  ssl_certificate_arn = module.acm_certificate.cert.arn
}
