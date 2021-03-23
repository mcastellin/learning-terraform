variable "dns_name" {
  type        = string
  description = "The DNS name of the route53 zone"
}

variable "subdomain" {
  type    = string
  default = ""
}

variable "tag_cert_name" {
  type        = string
  description = "The Name tag for the created certificate resource"
  default     = "HTTPS"
}