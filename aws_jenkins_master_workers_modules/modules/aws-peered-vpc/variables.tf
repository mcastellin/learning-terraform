variable "region_master" {
  type        = string
  description = "The AWS region for the master VPC"
}

variable "region_peer" {
  type        = string
  description = "The AWS region for the peered VPC"
}