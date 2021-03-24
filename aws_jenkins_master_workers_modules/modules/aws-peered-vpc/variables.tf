variable "region_master" {
  type        = string
  description = "The AWS region for the master VPC"
}

variable "region_peer" {
  type        = string
  description = "The AWS region for the peered VPC"
}

variable "master_vpc_cidr" {
  type        = string
  description = "the cidr block for the master vpc"
  default     = "10.0.0.0/16"
}

variable "tag_master_vpc" {
  type        = map(string)
  description = "optional tag values to apply to the master vpc"
  default = {
    "Name" = "master_vpc"
  }
}

variable "peer_vpc_cidr" {
  type        = string
  description = "the cidr block for the peered vpc"
  default     = "192.168.0.0/16"
}

variable "tag_peer_vpc" {
  type        = map(string)
  description = "optional tag values to apply to the peered vpc"
  default = {
    "Name" = "peer_vpc"
  }
}

variable "master_vpc_subnets_cird" {
  type        = list(string)
  description = "a list of cidr blocks for desired subnets in master vpc"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "peer_vpc_subnets_cidr" {
  type        = list(string)
  description = "a list of cidr blocks for desired subnets in peered vpc"
  default     = ["192.168.1.0/24"]
}