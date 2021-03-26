provider "aws" {
  profile = "default"
  region  = var.region_master
  alias   = "region_master"
}

provider "aws" {
  profile = "default"
  region  = var.region_workers
  alias   = "region_workers"
}