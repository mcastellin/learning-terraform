variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}

variable "region-worker" {
  type    = string
  default = "us-west-2"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}

variable "workers-count" {
  type    = number
  default = 1
}

variable "webserver-port" {
  type    = number
  default = 8080
}

# use this command to list the available hosted zones to get the Dns form
# aws route53 list-hosted-zones | jq '.HostedZones[0].Name'
variable "dns_name" {
  type = string
}