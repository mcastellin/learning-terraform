# to create the bucket: aws s3api create-bucket --bucket terraformstate78977
terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }

  # The backend will be defined in terragrunt
  backend "s3" {}
}