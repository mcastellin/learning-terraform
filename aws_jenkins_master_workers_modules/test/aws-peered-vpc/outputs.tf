output "vpc_id" {
  value = module.vpc.vpc_id
}

output "master_subnets" {
  value = module.vpc.master_subnets
}

output "peer_subnets" {
  value = module.vpc.peer_subnets
}

output "master_subnets_list" {
  value = module.vpc.master_subnets_list
}

output "peer_subnets_list" {
  value = module.vpc.peer_subnets_list
}