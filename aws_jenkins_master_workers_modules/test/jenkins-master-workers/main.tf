terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

module "vpc" {
  source = "../../modules/aws-peered-vpc"

  providers = {
    aws.region_master = aws.region_master
    aws.region_peer   = aws.region_workers
  }

  region_master = var.region_master
  region_peer   = var.region_workers
}

module "jenkins_master_workers" {
  source = "../../modules/jenkins-master-workers"

  depends_on = [
    module.vpc
  ]

  providers = {
    aws.region_master  = aws.region_master
    aws.region_workers = aws.region_workers
  }

  master_vpc  = module.vpc.master
  workers_vpc = module.vpc.peer

  workers_count = 2
}
