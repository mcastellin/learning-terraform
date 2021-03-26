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

  master_subnets_list  = module.vpc.master_subnets_list
  workers_subnets_list = module.vpc.peer_subnets_list
  master_vpc_id        = module.vpc.vpc_id.master
  workers_vpc_id       = module.vpc.vpc_id.peer
}
