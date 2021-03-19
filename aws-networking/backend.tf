# to create the bucket: aws s3api create-bucket --bucket terraformstate78977
terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile" # the name of the terraform state file we want
    bucket  = "terraformstate78977"
  }
}