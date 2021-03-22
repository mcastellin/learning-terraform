variable "profile" {
  type    = string
  default = "default"
}

variable "region_master" {
  type    = string
  default = "us-east-1"
}

variable "region_worker" {
  type    = string
  default = "us-west-2"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "webserver_port" {
  type    = number
  default = 8080
}

# use this command to list the available hosted zones to get the Dns form
# aws route53 list-hosted-zones | jq '.HostedZones[0].Name'
variable "dns_name" {
  type = string
}