# IaC - Jenkins Master-Worker Setup on AWS

This terraform project is my first infrastructure as code implementation with Terraform.
All resources are coded in a flat folder structure with multiple terraform files. In a second iteration
I'm going to implement the same infrastructure with Terraform modules to create reusable and more testable IaC snippets.

## How to run the Terraform scripts
This terraform setup uses an S3 backend that I have parametrised using Terragrunt.

I'm using a cloud lab on AWS that already has a Route53 default zone configured. To retrieve and set the zone I run the `setup.sh` script first

```bash
. ./setup.sh
```

Once the `setup.sh` script has set all environment variables with values read from the AWS account I can create the infrastructure with:

```bash
terragrunt init
terragrunt plan
terragrunt apply
```

## Additional configuration

An interesting configuration option is the `workers_count` variable. Use this with `terragrunt apply` to dynamically change the number of worker nodes to be deployed:

```bash
terragrunt apply -var "workers_count=2"
```
