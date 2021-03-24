terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

provider "aws" {
  profile = "default"
  region  = var.region_master
  alias   = "region_master"
}

provider "aws" {
  profile = "default"
  region  = var.region_peer
  alias   = "region_peer"
}

module "vpc" {
  source = "../../modules/aws-peered-vpc"

  providers = {
    aws.region_master = aws.region_master
    aws.region_peer   = aws.region_peer
  }

  region_master = var.region_master
  region_peer   = var.region_peer
}