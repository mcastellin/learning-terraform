remote_state {
    backend = "s3"
    config = {
        region = "us-east-1"
        bucket = "terraformstate8877"
        key = "${path_relative_to_include()}/terraform.tfstate"
        profile = "default"
    }
}

inputs = {
    workers-count = 1
    instance-type = "t3.micro"
}