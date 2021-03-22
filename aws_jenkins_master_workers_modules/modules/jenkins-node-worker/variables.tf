variable "aws_profile" {
  type        = string
  description = "The AWS credentials profile for Ansible dynamic inventory"
  default     = "default"
}

variable "region" {
  type        = string
  description = "The AWS region where the Jenkins master instance should be deployed"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where Jenkins master should be deployed"
}

variable "instance_type" {
  type        = string
  description = "The AWS instance type the Jenkins master node should run"
  default     = "t3.micro"
}

variable "ssh_key_file" {
  type        = string
  description = "The path to the ssh key file"
  default     = "~/.ssh/id_rsa"
}

variable "vpc_sec_group_ids" {
  type        = list(string)
  description = "A list of security groups to be attached to the Jenkins master instance"
}

variable "workers_count" {
  type        = number
  description = "The number of Jenkins worker instances"
  default     = 1
}

variable "master_ip" {
  type        = string
  description = "The IP address of the Jenkins master node"
}