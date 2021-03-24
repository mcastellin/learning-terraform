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
