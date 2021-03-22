variable "aws_profile" {
  type        = string
  description = "The AWS credentials profile for Ansible dynamic inventory"
  default     = "default"
}

variable "region" {
  type        = string
  description = "The AWS region where the Jenkins master instance should be deployed"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC we are deploying this resource"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where Jenkins master should be deployed"
}

variable "lb_subnets" {
  type        = list(string)
  description = "The list of subnets for the application load balancer"
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

variable "lb_sec_group_id" {
  type        = string
  description = "The security group ID for the load balancer"
}

variable "webserver_port" {
  type        = string
  description = "The port Jenkins is running on"
  default     = 8080
}

variable "acm_certificate_arn" {
  type        = string
  description = "The Arn of the https certificate"
}