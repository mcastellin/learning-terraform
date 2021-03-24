output "vpc_id" {
  value = {
    master = aws_vpc.vpc_master.id
    peer   = aws_vpc.vpc_peer.id
  }
}

output "master_subnets" {
  value = {
    for index, net in aws_subnet.master_subnets :
    "subnet_${index + 1}" => net.id
  }
}

output "peer_subnets" {
  value = {
    for index, net in aws_subnet.peer_subnets :
    "subnet_${index + 1}" => net.id
  }
}

output "master_subnets_list" {
  description = "same subnet ids presented as a list"
  value       = [for net in aws_subnet.master_subnets : net.id]
}

output "peer_subnets_list" {
  description = "same subnet ids presented as a list"
  value       = [for net in aws_subnet.peer_subnets : net.id]
}
