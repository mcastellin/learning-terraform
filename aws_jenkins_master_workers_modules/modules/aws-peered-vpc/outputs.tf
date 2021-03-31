# -------------------------------------------
# New output definition
# -------------------------------------------
output "master" {
  value = {
    id      = aws_vpc.vpc_master.id
    region  = var.region_master
    cidr    = var.master_vpc_cidr
    subnets = [for net in aws_subnet.master_subnets : net.id]
  }
}

output "peer" {
  value = {
    id      = aws_vpc.vpc_peer.id
    region  = var.region_peer
    cidr    = var.peer_vpc_cidr
    subnets = [for net in aws_subnet.peer_subnets : net.id]
  }
}


# -------------------------------------------
# Deprecated outputs. WARNING: do not use!!!
# -------------------------------------------
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

