# aws-peered-vpc module
# Create a peered VPC configuration on AWS
terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

locals {
  master_subnets_count = length(var.master_vpc_subnets_cird)
  peer_subnets_count   = length(var.peer_vpc_subnets_cidr)
}

# Create VPCs
resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = var.master_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    for key, value in var.tag_master_vpc :
    key => value
  }
}

resource "aws_vpc" "vpc_peer" {
  provider             = aws.region_peer
  cidr_block           = var.peer_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    for key, value in var.tag_peer_vpc :
    key => value
  }
}

# Create Internet Gateways
resource "aws_internet_gateway" "igw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
}

resource "aws_internet_gateway" "igw_peer" {
  provider = aws.region_peer
  vpc_id   = aws_vpc.vpc_peer.id
}

# create data resource
data "aws_availability_zones" "azs" {
  provider = aws.region_master
  state    = "available"
}

resource "aws_subnet" "master_subnets" {
  provider = aws.region_master
  count    = local.master_subnets_count

  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = element(var.master_vpc_subnets_cird, count.index)
}

data "aws_availability_zones" "peer_azs" {
  provider = aws.region_peer
  state    = "available"
}

resource "aws_subnet" "peer_subnets" {
  provider = aws.region_peer
  count    = local.peer_subnets_count

  availability_zone = element(data.aws_availability_zones.peer_azs.names, count.index)
  vpc_id            = aws_vpc.vpc_peer.id
  cidr_block        = element(var.peer_vpc_subnets_cidr, count.index)
}

# VPC Peering

# Connection request
resource "aws_vpc_peering_connection" "master_peer" {
  provider    = aws.region_master
  peer_vpc_id = aws_vpc.vpc_peer.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region_peer
}

# Connection accepter
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region_peer
  vpc_peering_connection_id = aws_vpc_peering_connection.master_peer.id
  auto_accept               = true # auto-accept only works because VPCs are in the same AWS account
}


# Creating routing tables
resource "aws_route_table" "internet_route" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # routing connection requests to peered vpc through the vpc_peering connection
  dynamic "route" {
    for_each = var.peer_vpc_subnets_cidr
    iterator = peer_cidr
    content {
      cidr_block                = peer_cidr.value
      vpc_peering_connection_id = aws_vpc_peering_connection.master_peer.id
    }
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    "Name" = "Master-Region-RT"
  }
}

resource "aws_main_route_table_association" "set_master_default_rt_assoc" {
  provider       = aws.region_master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}


resource "aws_route_table" "internet_route_peer" {
  provider = aws.region_peer
  vpc_id   = aws_vpc.vpc_peer.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_peer.id
  }

  # routing connection requests to master vpc through the vpc_peering connection
  dynamic "route" {
    for_each = var.master_vpc_subnets_cird
    iterator = master_cidr
    content {
      cidr_block                = master_cidr.value
      vpc_peering_connection_id = aws_vpc_peering_connection.master_peer.id
    }
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    "Name" = "Peer-Region-RT"
  }
}

resource "aws_main_route_table_association" "set_peer_default_rt_assoc" {
  provider       = aws.region_peer
  vpc_id         = aws_vpc.vpc_peer.id
  route_table_id = aws_route_table.internet_route_peer.id
}