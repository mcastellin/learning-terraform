# Create VPCs
resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "master-vpc-jenkins"
  }
}


resource "aws_vpc" "vpc_worker" {
  provider             = aws.region_worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "worker-vpc-jenkins"
  }
}

# Create Internet Gateways
resource "aws_internet_gateway" "igw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
}

resource "aws_internet_gateway" "igw-worker" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_worker.id
}

# create data resource
data "aws_availability_zones" "azs" {
  provider = aws.region_master
  state    = "available"
}

resource "aws_subnet" "subnet_1" {
  provider          = aws.region_master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "subnet_2" {
  provider          = aws.region_master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "subnet_1_worker" {
  provider   = aws.region_worker
  vpc_id     = aws_vpc.vpc_worker.id
  cidr_block = "192.168.1.0/24"
}

# VPC Peering

# Connection request
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region_master
  peer_vpc_id = aws_vpc.vpc_worker.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region_worker
}

# Connection accepter
resource "aws_vpc_peering_connection_accepter" "accept-peering" {
  provider                  = aws.region_worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
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
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    "Name" = "Master-Region-RT"
  }
}

resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region_master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}


resource "aws_route_table" "internet_route_worker" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_worker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-worker.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    "Name" = "Worker-Region-RT"
  }
}

resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region_worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.internet_route_worker.id
}