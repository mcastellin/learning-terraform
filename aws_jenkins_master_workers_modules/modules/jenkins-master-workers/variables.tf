# ----------------------------------------------------
# Network configuration
# ----------------------------------------------------
variable "master_subnets_list" {
  type        = list(string)
  description = "the list of subnets for the master instance autoscaling group"
}

variable "workers_subnets_list" {
  type        = list(string)
  description = "the list of subnets for the worker instances autoscaling group"
}

variable "master_vpc_id" {
  type = string
}

variable "workers_vpc_id" {
  type = string
}

# ----------------------------------------------------
# Instance configuration
# ----------------------------------------------------
variable "master_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "workers_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "master_ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "workers_ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "webserver_port" {
  type    = number
  default = 8080
}

# ----------------------------------------------------
# Autoscaling
# ----------------------------------------------------
variable "master_placement_strategy" {
  type        = string
  default     = "partition"
  description = "the cluster placement group strategy for ec2 instances running Jenkins master nodes"
  validation {
    condition     = can(regex("^(cluster|partition|spread)$", var.master_placement_strategy))
    error_message = "Invalid value for placement strategy. Allowed values: cluster|partition|spread."
  }
}