# ----------------------------------------------------
# Network configuration
# ----------------------------------------------------
variable "master_vpc" {
  description = "the vpc configuration that will host Jenkins master node"
  type = object({
    id      = string
    region  = string
    cidr    = string
    subnets = list(string)
  })
}

variable "workers_vpc" {
  description = "the vpc configuration that will host Jenkins worker nodes"
  type = object({
    id      = string
    region  = string
    cidr    = string
    subnets = list(string)
  })
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
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

variable "ssl_enabled" {
  type    = bool
  default = false
}

variable "ssl_certificate_arn" {
  type        = string
  description = "the arn of the ssl certificate for the application load balancer"
  default     = ""
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

variable "workers_count" {
  type        = string
  default     = 1
  description = "the number of Jenkins worker nodes"
}