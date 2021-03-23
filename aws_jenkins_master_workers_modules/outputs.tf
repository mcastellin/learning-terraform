output "Jenkins-Main-Node-Public-IP" {
  value = module.jenkins_node_master.public_ip
}

output "Jenkins-Workers-Public-IP" {
  value = module.jenkins_node_workers.public_ips
}

output "Jenkins-URL" {
  value = aws_route53_record.jenkins.fqdn
}