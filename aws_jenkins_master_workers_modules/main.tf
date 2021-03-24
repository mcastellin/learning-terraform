
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


module "jenkins_node_master" {
  source = "./modules/jenkins-node-master"

  depends_on = [
    module.vpc
  ]

  providers = {
    aws = aws.region_master
  }

  region            = var.region_master
  vpc_id            = module.vpc.vpc_id.master
  subnet_id         = module.vpc.master_subnets.subnet_1
  instance_type     = var.instance_type
  webserver_port    = var.webserver_port
  vpc_sec_group_ids = [aws_security_group.jenkins-sg.id]

  lb_subnets      = [module.vpc.master_subnets.subnet_1, module.vpc.master_subnets.subnet_2]
  lb_sec_group_id = aws_security_group.lb-sg.id

  acm_certificate_arn = module.acm_certificate.cert.arn
}

module "jenkins_node_workers" {
  source = "./modules/jenkins-node-worker"

  providers = {
    aws = aws.region_worker
  }

  depends_on = [
    module.jenkins_node_master
  ]

  workers_count     = var.workers_count
  region            = var.region_worker
  subnet_id         = module.vpc.peer_subnets.subnet_1
  instance_type     = var.instance_type
  vpc_sec_group_ids = [aws_security_group.jenkins-worker-sg.id]
  master_ip         = module.jenkins_node_master.private_ip
}