output "vpc_id" {
  value = {
    master = aws_vpc.vpc_master.id
    peer   = aws_vpc.vpc_peer.id
  }
}

output "master_subnets" {
  value = {
    subnet_1 = aws_subnet.subnet_1_master.id
    subnet_2 = aws_subnet.subnet_2_master.id
  }
}

output "peer_subnets" {
  value = {
    subnet_1 = aws_subnet.subnet_1_peer.id
  }
}
