# learning-terraform
I want to test out Terraform capabilities by implementing a cloudformation build with it

TODO: 
- [ ] draft some idea for a pipeline to build with Terraform
- [ ] register for another Cloud account other than AWS to test out multi cloud
- [ ] I also want to try build a bot that acts upon PR changes and comment back or move statuses or merge
- [ ] learn and apply all security constraint that are considered best practices in aws like using security group ingress 
- [ ] Must deploy and application to K8s cluster or at least ECS
- [ ] learn how to manage logs in the cloud and use aws or some other tools like elasticsearch for aggregation
- [ ] software security? How can I test out software security checks in my pipeline?
- [ ] try out some new network configuration I didn't try before
- [ ] build a small command line automation in go
- [ ] start working with deploying a managed database
- [ ] use SNS to collect prometheus alerts

### Recurring terms
- [ ] jenkins
- [ ] vm provisioning puppet, chef, ansible
- [ ] scripting language (python, go, ruby)
- [ ] linux administration


# First experiment with Terraform

In this first experiment we deploy a container in local Docker with Terraform

```
terraform init          # initializes the .terraform directory to contain the status
terraform apply         # prepares the plan and apply modifications

terraform destroy       # deletes all created resources
```
