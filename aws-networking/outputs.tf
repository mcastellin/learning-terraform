output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Workers-Public-IP" {
  value = {
    for instance in aws_instance.jenkins-workers :
    instance.id => instance.public_ip
  }
}

output "LB-Dns-Name" {
  value = aws_lb.application-lb.dns_name
}

output "Url" {
  value = aws_route53_record.jenkins.fqdn
}