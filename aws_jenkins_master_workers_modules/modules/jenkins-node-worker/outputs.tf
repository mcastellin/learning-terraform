output "public_ips" {
  value = {
    for instance in aws_instance.jenkins-workers :
    instance.id => instance.public_ip
  }
}