output "public_ip" {
  value = aws_instance.jenkins-master.public_ip
}

output "private_ip" {
  value = aws_instance.jenkins-master.private_ip
}

output "alb_zone_id" {
  value = aws_lb.application-lb.zone_id
}

output "alb_dns_name" {
  value = aws_lb.application-lb.dns_name
}